# Introduction

This repository holds several `learnr` tutorials for the class **Multivariate Data Analysis** within the FOS-course of the LUMC.

The tutorials are separated by year.

# Installation

All tutorials are run from a Docker container running a Shiny server. To build the Docker container run:

```
docker build -t FOS2026 .
```

Run the Docker container with (adjust port when needed):

```
docker run -d -p 3838:3838 FOS2026
```

# Usage

To access the tutorials go to `http://localhost:3838/FOS/2026/`

