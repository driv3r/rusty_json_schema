extern crate libc;

use jsonschema::JSONSchema;
use serde_json::Value;

use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_uint};

/*
 * Our wrapper struct for schema, we need to hold
 * onto value in order to not have it freed up.
 */
pub struct Validator {
    schema: &'static JSONSchema,
}

impl Validator {
    /*
     * With Box::leak we avoid freeing up of schema,
     * we free them up separately in the Drop implementation
     */
    fn new(schema: Value) -> Validator {
        let boxed_compile: &'static JSONSchema =
            Box::leak(Box::new(JSONSchema::compile(&schema).unwrap()));

        Validator {
            schema: boxed_compile,
        }
    }

    fn is_valid(&self, event: &Value) -> bool {
        self.schema.is_valid(event)
    }

    fn validate(&self, event: &Value) -> Vec<String> {
        let mut errors: Vec<String> = vec![];

        if let Err(validation_errors) = self.schema.validate(event) {
            for error in validation_errors {
                let path = match format!("{}", error.instance_path).as_str() {
                    "" => "/".to_string(),
                    p => p.to_string(),
                };

                errors.push(format!("path \"{}\": {}", path, error));
            }
        }

        errors
    }
}

impl Drop for Validator {
    /*
     * Free up schema with value by "materializing" them,
     * otherwise they will leak memory.
     */
    fn drop(&mut self) {
        unsafe {
            Box::from_raw(self.schema as *const _ as *mut JSONSchema);
        }
    }
}

#[repr(C)]
pub struct Array {
    data: *mut *mut c_char,
    len: c_uint,
    cap: c_uint,
}

impl Array {
    fn from_vec(from: Vec<String>) -> Self {
        let mut converted: Vec<*mut c_char> = from
            .into_iter()
            .map(|s| CString::new(s).unwrap().into_raw())
            .collect();

        converted.shrink_to_fit();

        let len = converted.len();
        let cap = converted.capacity();
        let result = Array {
            data: converted.as_mut_ptr(),
            len: len as c_uint,
            cap: cap as c_uint,
        };

        std::mem::forget(converted);

        result
    }
}

fn to_string(ptr: *const c_char) -> &'static CStr {
    unsafe {
        assert!(!ptr.is_null());
        CStr::from_ptr(ptr)
    }
}

#[no_mangle]
pub extern "C" fn validator_new(c_schema: *const c_char) -> *mut Validator {
    let raw_schema = to_string(c_schema);
    let schema = serde_json::from_slice(raw_schema.to_bytes()).unwrap();
    let validator = Validator::new(schema);

    Box::into_raw(Box::new(validator))
}

#[no_mangle]
#[allow(clippy::not_unsafe_ptr_arg_deref)]
pub extern "C" fn validator_free(ptr: *mut Validator) {
    if ptr.is_null() {
        return;
    }

    unsafe {
        Box::from_raw(ptr);
    }
}

#[no_mangle]
#[allow(clippy::not_unsafe_ptr_arg_deref)]
pub extern "C" fn validator_is_valid(ptr: *const Validator, event: *const c_char) -> bool {
    let validator = unsafe {
        assert!(!ptr.is_null());
        &*ptr
    };

    let raw_event = to_string(event);
    let event: Value = serde_json::from_slice(raw_event.to_bytes()).unwrap();

    validator.is_valid(&event)
}

#[no_mangle]
#[allow(clippy::not_unsafe_ptr_arg_deref)]
pub extern "C" fn validator_validate(ptr: *const Validator, event: *const c_char) -> *mut Array {
    let validator = unsafe {
        assert!(!ptr.is_null());
        &*ptr
    };

    let raw_event = to_string(event);
    let event: Value = serde_json::from_slice(raw_event.to_bytes()).unwrap();
    let errors = validator.validate(&event);
    let result = Array::from_vec(errors);
    let boxed = Box::new(result);

    Box::into_raw(boxed)
}

#[no_mangle]
#[allow(clippy::not_unsafe_ptr_arg_deref)]
pub extern "C" fn array_free(ptr: *mut Array) {
    if ptr.is_null() {
        return;
    }

    unsafe {
        let array = Box::from_raw(ptr);
        let data = Vec::from_raw_parts(array.data, array.len as usize, array.cap as usize);

        for string in data {
            let _ = CString::from_raw(string);
        }
    }
}

#[cfg(test)]
mod tests {
    // Note this useful idiom: importing names from outer (for mod tests) scope.
    use super::*;
    use std::ffi::CString;

    /*
     * Simple sanity check if everything works together
     */
    #[test]
    fn test_valid_event() {
        let validator = validator_new(helper_c_schema().as_ptr());

        assert!(validator_is_valid(validator, helper_c_valid().as_ptr()));

        assert!(!validator_is_valid(validator, helper_c_invalid().as_ptr()));

        validator_free(validator);
    }

    #[test]
    fn test_validate_event_when_valid() {
        let validator = validator_new(helper_c_schema().as_ptr());
        let raw_result = validator_validate(validator, helper_c_valid().as_ptr());
        let result = unsafe { helper_validate_result_as_vec(raw_result) };

        let expectation: Vec<String> = vec![];

        assert_eq!(result, expectation);

        validator_free(validator);
    }

    #[test]
    fn test_validate_event_when_invalid() {
        let validator = validator_new(helper_c_schema().as_ptr());
        let raw_result = validator_validate(validator, helper_c_invalid().as_ptr());
        let result = unsafe { helper_validate_result_as_vec(raw_result) };

        let expectation: Vec<String> = vec![
            String::from("path \"/bar\": \"rusty\" is not of type \"number\""),
            String::from("path \"/foo\": 1 is not of type \"string\""),
            String::from("path \"/\": \"baz\" is a required property"),
        ];

        assert_eq!(result, expectation);

        validator_free(validator);
    }

    /*
     * Test helpers
     */
    fn helper_c_schema() -> CString {
        CString::new(
            r#"{
                "properties":{
                    "foo": {"type": "string"},
                    "bar": {"type": "number"},
                    "baz": {}
                },
                "required": ["baz"]
            }"#,
        )
        .unwrap()
    }

    fn helper_c_valid() -> CString {
        CString::new(
            r#"{
                "foo": "rusty",
                "bar": 1,
                "baz": "rusty"
            }"#,
        )
        .unwrap()
    }

    fn helper_c_invalid() -> CString {
        CString::new(
            r#"{
                "foo": 1,
                "bar": "rusty"
            }"#,
        )
        .unwrap()
    }

    unsafe fn helper_validate_result_as_vec(result: *mut Array) -> Vec<String> {
        let raw = Box::from_raw(result);

        Vec::from_raw_parts(raw.data, raw.len as usize, raw.cap as usize)
            .into_iter()
            .map(|x| CString::from_raw(x).into_string().unwrap())
            .collect()
    }
}
