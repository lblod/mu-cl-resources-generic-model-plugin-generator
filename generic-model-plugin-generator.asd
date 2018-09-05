(asdf:defsystem :generic-model-plugin-generator
  :name "generic-model-plugin-generator"
  :author "Aad Versteden <madnificent@gmail.com>"
  :version "0.0.1"
  :maintainer "Aad Versteden <madnificent@gmail.com>"
  :licence "MIT"
  :description "Outputs a Turtle file for the generic-model-plugin-generator."
  :serial t
  :depends-on (mu-cl-resources)
  :components ((:file "packages")
               (:file "generic-model-plugin-generator")))
