extern crate libc;

use jsonschema::JSONSchema;
use serde_json::Value;

use std::ffi::{CStr, CString};
use std::os::raw::c_char;

/*
 * Our wrapper struct for schema and schema value,
 * we need to hold onto value in order to not have
 * it freed up, as JSONSchema uses it as reference.
 */
pub struct Validator {
    schema: &'static JSONSchema<'static>,
    schema_value: &'static Value,
}

impl Validator {
    /*
     * With Box::leak we avoid freeing up of schema
     * and schema value, we free them up separately
     * in the Drop implementation
     */
    fn new(schema: Value) -> Validator {
        let boxed_schema: &'static Value = Box::leak(Box::new(schema));
        let boxed_compile: &'static JSONSchema<'static> = Box::leak(Box::new(JSONSchema::compile(boxed_schema).unwrap()));

        Validator {
            schema: boxed_compile,
            schema_value: boxed_schema,
        }
    }

    fn is_valid(&self, event: &Value) -> bool {
        self.schema.is_valid(event)
    }

    fn validate(&self, event: &Value) -> Vec<*const c_char> {
        let mut errors: Vec<*const c_char> = vec![];

        if let Err(validation_errors) = self.schema.validate(event) {
            for error in validation_errors {
                if let Ok(c_string) = CString::new(error.to_string()) {
                    errors.push(c_string.into_raw());
                }
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
            Box::from_raw(self.schema_value as *const _ as *mut Value);
        }
    }
}

#[repr(C)]
pub struct Array {
    len: libc::size_t,
    data: *const libc::c_void,
}

impl Array {
    fn from_vec<T>(mut vec: Vec<T>) -> Array {
        vec.shrink_to_fit();

        let array = Array {
            data: vec.as_ptr() as *const libc::c_void,
            len: vec.len() as libc::size_t
        };

        std::mem::forget(vec);

        array
    }
}

impl Drop for Array {
    fn drop(&mut self) {
        unsafe {
            Box::from_raw(self.data as *const _ as *mut Vec<*const c_char>);
        }
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
    let raw_schema  = to_string(c_schema);
    let schema = serde_json::from_slice(raw_schema.to_bytes()).unwrap();
    let validator = Validator::new(schema);

    Box::into_raw(Box::new(validator))
}

#[no_mangle]
pub extern "C" fn validator_free(ptr: *mut Validator) {
    if ptr.is_null() {
        return;
    }

    unsafe {
        Box::from_raw(ptr);
    }
}

#[no_mangle]
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
pub extern "C" fn validator_validate(ptr: *const Validator, event: *const c_char) -> *mut Array {
    let validator = unsafe {
        assert!(!ptr.is_null());
        &*ptr
    };

    let raw_event = to_string(event);
    let event: Value = serde_json::from_slice(raw_event.to_bytes()).unwrap();
    let errors = validator.validate(&event);
    let result = Array::from_vec(errors);

    Box::into_raw(Box::new(result))
}

#[no_mangle]
pub extern "C" fn array_free(array: *mut Array) {
    if array.is_null() {
        return;
    }

    unsafe {
        Box::from_raw(array);
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
        let schema = CString::new("{\"$schema\":\"http://json-schema.org/draft-07/schema#\",\"type\":\"array\",\"items\":[{\"type\":\"number\",\"exclusiveMaximum\":10}]}").unwrap();
        let valid_event = CString::new("[9]").unwrap();
        let invalid_event = CString::new("[22]").unwrap();

        let c_schema_ptr: *const c_char = schema.as_ptr();
        let c_valid_event_ptr: *const c_char = valid_event.as_ptr();
        let c_invalid_event_ptr: *const c_char = invalid_event.as_ptr();

        let validator = validator_new(c_schema_ptr);

        assert!(validator_is_valid(validator, c_valid_event_ptr));
        assert!(!validator_is_valid(validator, c_invalid_event_ptr));

        validator_free(validator);
    }
}
