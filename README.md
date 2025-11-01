## Product: This is a dataone tagline for the product

- **Authors**: Jones, Matthew (https://orcid.org/0000-0003-0077-4738); ...
- **License**: [Apache 2](http://opensource.org/licenses/Apache-2.0)
- [Package source code on GitHub](https://github.com/NCEAS/vbshiny)
- [**Submit Bugs and feature requests**](https://github.com/NCEAS/vbshiny/issues)
- Contact us: support@dataone.org

A Helm chart to build and deploy a Shiny application on the `rocker/shiny-verse` image.

VegBank is an open source, community project.  We [welcome contributions](./CONTRIBUTING.md) in many forms, including code, graphics, documentation, bug reports, testing, etc.


## Documentation

Documentation is a work in progress, and can be found ...

## Development build

Build the Docker image with:

```
`docker build -t vbshiny:0.1.0 .
```

Then publish the image to a public image repository.
i
Deploy by providing a custom values file and installing with helm:

```
helm upgrade --install -n <namespace> <release> .
```

## License
```
Copyright [2024] [Regents of the University of California]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

## Acknowledgements

Work on this package was supported by:

- California Department of Fish and Wildlife
- The ESA Panel on Vegetation Classification

Additional support was provided for collaboration by the National Center for Ecological Analysis and Synthesis, a Center funded by the University of California, Santa Barbara, and the State of California.

[![nceas_footer](https://www.nceas.ucsb.edu/sites/default/files/2020-03/NCEAS-full%20logo-4C.png)](https://www.nceas.ucsb.edu)
