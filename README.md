# Schlaeferprojekt

Intelligent Systems in Medicine Project Seminar

## Data

The data can be downloaded from the TUHH cloud.
After cloning this repository you need to create the following additional directories in your `Schlaeferprojekt` directory to be compatible with the code:

```
.
├── data
│   ├── metal
│   │   ├── forces
│   │   └── oct
│   └── phantoms
│       ├── forces
│       └── oct
├── models
└── preprocessed_data
    ├── metal
    │   ├── forces
    │   └── oct
    └── phantoms
        ├── forces
        └── oct
```

## Code

Please use MATLAB R2017b.
After downloading the data run `preprocess_data.m` before you run any other MATLAB script.
It will process and write the measured data to the subdirectories of `preprocessed_data`.
