# Resources generator

Generates a turtle-file which can be used for the [generic-model-plugin](https://github.com/lblod/ember-rdfa-editor-generic-model-plugin) by introspecting a domain.lisp

## Example usage

Running in a default [mu-project](https://github.com/mu-semtech/mu-project)

```
    docker run -v /tmp/generator-output/:/output/ -v `pwd`/config/resources:/config lblod/resources-generic-model-plugin-generator
```

The output can be used as the ttl file for a migration.  You will likely want to remove some contents from the ttl file.  Most prominent candidates are complete resources which are not necessary, as well as some of the contents in the displayProperties string.
