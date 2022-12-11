# Symbolic Regressor

Lightweight symbolic regressor written in `Julia` that uses genetic algorithms to find expressions that model a given dataset.

## Structure

### `configs`
Folder that holds the configuration files in `.json` format. 

### `data`
Folder that contains the datasets in `.csv` format. Each dataset has two files: one corresponding to the inputs, that has as many columns as input parameters, and one for the outputs that has a single column.

### `src`
* `SymbolicR.jl`
* `GTree.jl`
* `GTPopulation.jl`
* `Utils.jl`

## Usage

> `julia SymbolicR.jl --help`

Packages used:
* `CSV`
* `JSON`
* `DataFrames`
* `SymbolicUtils`
  * only required if the user wants to simplify the resulting expression in a separated terminal.
  
### Default Configurations

* `kepler`
* `noiseless-kepler`
* `gravitational-law`
* `sine-no-sine`
* `sine-pow2`
 