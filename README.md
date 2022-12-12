# Symbolic Regressor

Lightweight symbolic regressor written in `Julia` that uses genetic algorithms to find expressions that model datasets.

## Usage
See
> `julia SymbolicR.jl --help`

Required packages:
* `CSV`
* `JSON`
* `DataFrames`
* `SymbolicUtils`
  
### Default Configurations

* `kepler`
    * kepler's third law.
* `noisy-kepler`
    * kepler's third law with noise.
* `newton`
    * newton's law of universal gravitation.
* `sine`
    * sine without the sine function.
* `sine2`
    * sine squared without the sine function.
