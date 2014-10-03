kelm
====

kelm, Kaos Erlang Library Manager, is a tool to package, publish, install and otherwise manage erlang libraries.

Packages can be published with source, binary or a combination of the two. When installing, if there is only source version available for your system, you have the option to let kelm download the sources and build it behind the scenes, publish the binary results and the install that. The benefit of publishing the result is for the next user installing on an equal system when a binary version of the package is already available.

There are three parts to the kelm eco-system. The cli command, `kelm` which operates on the client machine. On the backend is `kelmd` exposing a REST-ful api to its clients, and `kelm-web` is a web based GUI to `kelmd`.

When working with packages, `kelm` uses package manifests describing what goes into a package, and how to build and test it, as well as which other packages it depends upon.
