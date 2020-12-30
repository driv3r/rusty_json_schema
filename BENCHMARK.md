# Benchmarks

Compare various gems doing json schema validation.

At the moment we are only looking at gems implementing Draft 7 of json schema.

Update by running:

```bash
bundle exec ruby spec/benchmark.rb
```

> Run against:
>
> - #37~20.04.2-Ubuntu @ kernel: 5.8.0-34-generic
> - AMD Ryzen 9 3900X 12-Core
> - 32GB RAM

## Gem#valid?

Simple boolean result.

> Results in instructions/validations per second.

<table>
  <thead>
    <tr>
      <th rowspan=2 >Gem</th>
      <th colspan=2 >Tiny Schema</th>
      <th colspan=2 >Schema</th>
      <th >Big Schema</th>
    </tr>
    <tr>
      <th>Valid</th>
      <th>Invalid</th>
      <th>Valid</th>
      <th>Invalid</th>
      <th>Valid</th>
    </tr>
  </thead>

  <tbody>
    <tr>
      <th>RustyJSONSchema</th>
      <td>  362966.1</td>
      <td>  423275.2</td>
      <td>  285533.3</td>
      <td>  303590.7</td>
      <td>      12.8</td>
    </tr>
    <tr>
      <th>JSONSchemer</th>
      <td>   98019.9 - 3.70x </td>
      <td>  258478.2 - 1.64x </td>
      <td>   14239.3 - 20.05x </td>
      <td>  166074.7 - 1.83x </td>
      <td>       0.5 - 25.42x </td>
    </tr>
  </tbody>
</table>

## Gem#validate

Returns a list of validation errors if any

> Results in instructions/validations per second.

<table>
  <thead>
    <tr>
      <th rowspan=2 >Gem</th>
      <th colspan=2 >Tiny Schema</th>
      <th colspan=2 >Schema</th>
      <th >Big Schema</th>
    </tr>
    <tr>
      <th>Valid</th>
      <th>Invalid</th>
      <th>Valid</th>
      <th>Invalid</th>
      <th>Valid</th>
    </tr>
  </thead>

  <tbody>
    <tr>
      <th>RustyJSONSchema</th>
      <td>  180723.6</td>
      <td>  148233.0</td>
      <td>  151118.6</td>
      <td>  121512.6</td>
      <td>      13.0</td>
    </tr>
    <tr>
      <th>JSONSchemer</th>
      <td>   98568.1 - 1.83x </td>
      <td>   99045.2 - 1.50x </td>
      <td>   14385.3 - 10.51x </td>
      <td>   12263.2 - 9.91x </td>
      <td>       0.5 - 26.02x </td>
    </tr>
  </tbody>
</table>

