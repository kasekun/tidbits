# pytree
Print the local-module dependency tree of a python module

## Setup
TODO(jesse): build as package

## Usage

The usage pattern is
```sh
python pytree.py "your_module.py" 
```

## Example

```sh
python pytree.py main.py
main.py
├── helper_types.py
├── monca_bayes.py
│   ├── helper_types.py
│   └── monca_client.py
├── monca_client.py
├── plotting.py
│   ├── helper_types.py
│   └── utils.py
├── pymc3_bayes.py
│   ├── helper_types.py
│   ├── monca_client.py
│   └── utils.py
└── utils.py
```


Note if there is a circular dependency, this will be skipped and a warning printed (e.g., with deliberate circular import)

```sh
Circular dependency! Skipping: plotting <> helper_types
Circular dependency! Skipping: helper_types <> plotting
compare.py
├── helper_types.py
│   └── plotting.py
│       └── utils.py
├── monca_bayes.py
│   ├── helper_types.py
│   │   └── plotting.py
│   │       └── utils.py
│   └── monca_client.py
├── monca_client.py
├── plotting.py
│   ├── helper_types.py
│   └── utils.py
├── pymc3_bayes.py
│   ├── helper_types.py
│   │   └── plotting.py
│   │       └── utils.py
│   ├── monca_client.py
│   └── utils.py
└── utils.py
```
