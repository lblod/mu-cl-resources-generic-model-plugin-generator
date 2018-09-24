(in-package :generic-model-plugin-generator)

;;; supporting functions

(defun hash-table-values (hash-table)
  "Yields a list containing the hash-table values in the store."
  (loop for value being the hash-values of hash-table
     collect value))

;;; classes

(defclass ld-resource-instance ()
  ((resource :initarg :resource :reader resource)
   (uri :reader resource-uri)
   (uuid :reader resource-uuid)))

(defmethod initialize-instance :after ((resource ld-resource-instance) &key &allow-other-keys)
  (with-slots (resource uri uuid)
      resource
    (setf uuid (mu-support:make-uuid))
    (setf uri (format nil "<https://data.lblod.info/id/rdf-resources/~A>" uuid))))

(defclass ld-property-instance ()
  ((slot :initarg :slot :reader resource-slot)
   (uri :reader property-uri)
   (uuid :reader property-uuid)))

(defmethod initialize-instance :after ((property ld-property-instance) &key &allow-other-keys)
  ;; generate a URI for this specific slot
  (with-slots (slot uri uuid)
      property
    (setf uuid (mu-support:make-uuid))
    (setf uri (format nil "<http://data.lblod.info/id/rdf-properties/~A>" uuid))))

(defclass ld-relation-instance ()
  ((link :initarg :link :reader link)
   (uri :reader relation-uri)
   (uuid :reader relation-uuid)))

(defmethod initialize-instance :after ((relation ld-relation-instance) &key &allow-other-keys)
  ;; generate a URI for this specific slot
  (with-slots (slot uri uuid)
      relation
    (setf uuid (mu-support:make-uuid))
    (setf uri (format nil "<http://data.lblod.info/id/rdfs-relations/~A>" uuid))))

;;; spaghetti generating turtle

(defun generate-resources ()
  "This is the public entry of this microservice.  It orchestrates the
   generation of all services."
  (let* ((resource-map (make-ld-resource-instance-map))
         (ttl (format nil "~A~%~{~A~%~}"
                      (default-types-string)
                      (mapcar (lambda (resource)
                                (generate-resource resource resource-map))
                              (hash-table-values resource-map)))))
    (format t "~&~%This is the contents for the turtle file~%========================================~%~%")
    (format t "~A" ttl)
    (when (find :docker *features*)
      (let ((file-path "/output/generic-model-plugin-resources.ttl"))
        (ensure-directories-exist "/output")
        (with-open-file (output file-path :direction :output :if-does-not-exist :create :if-exists :supersede)
          (format output ttl)
          (format t "~&~%You can also find these contents in the container on ~A" file-path))))))

(defun make-ld-resource-instance-map ()
  "Creates a map linking the resources to the ld-resource-instance
  objects."
  (let ((resource-instance-map (make-hash-table)))
    (dolist (resource (all-resources))
      (setf (gethash resource resource-instance-map)
            (make-instance 'ld-resource-instance :resource resource)))
    resource-instance-map))

(defun default-types-string ()
  "Yields a string containing the default types to be emitted."

  "<http://data.lblod.info/id/rdfs-classes/primitive/string> a <http://www.w3.org/2000/01/rdf-schema#Class>;
   <http://mu.semte.ch/vocabularies/core/uuid> \"ce9b06b7-13ad-4b08-9e10-9ace3328614e\" ;
   <http://mu.semte.ch/vocabularies/ext/isPrimitive> true;
   <http://mu.semte.ch/vocabularies/ext/rdfaType> <http://www.w3.org/2001/XMLSchema#string>;
   <http://www.w3.org/2000/01/rdf-schema#label> \"string\" .

   <http://data.lblod.info/id/rdfs-classes/primitive/number> a <http://www.w3.org/2000/01/rdf-schema#Class>;
   <http://mu.semte.ch/vocabularies/core/uuid> \"bcbdbf55-242f-4d9f-8651-826f7d1d0ca4\" ;
   <http://mu.semte.ch/vocabularies/ext/isPrimitive> true;
   <http://mu.semte.ch/vocabularies/ext/rdfaType> <http://www.w3.org/2001/XMLSchema#number>;
   <http://www.w3.org/2000/01/rdf-schema#label> \"number\" .

   # TODO
   <http://data.lblod.info/id/rdfs-classes/primitive/boolean> a <http://www.w3.org/2000/01/rdf-schema#Class>;
   <http://mu.semte.ch/vocabularies/core/uuid> \"c5addfd1-60e5-4b9e-84a7-c00ccd3a1acb\" ;
   <http://mu.semte.ch/vocabularies/ext/isPrimitive> true;
   <http://mu.semte.ch/vocabularies/ext/rdfaType> <http://www.w3.org/2001/XMLSchema#string>;
   <http://www.w3.org/2000/01/rdf-schema#label> \"boolean\" .

   <http://data.lblod.info/id/rdfs-classes/primitive/date> a <http://www.w3.org/2000/01/rdf-schema#Class>;
   <http://mu.semte.ch/vocabularies/core/uuid> \"fb7b574d-fa19-43d7-8a30-cdbf54b33d63\" ;
   <http://mu.semte.ch/vocabularies/ext/isPrimitive> true;
   <http://mu.semte.ch/vocabularies/ext/rdfaType> <http://www.w3.org/2001/XMLSchema#date>;
   <http://www.w3.org/2000/01/rdf-schema#label> \"date\" .

   # fixed to be dateTime rather than datetime
   <http://data.lblod.info/id/rdfs-classes/primitive/datetime> a <http://www.w3.org/2000/01/rdf-schema#Class>;
   <http://mu.semte.ch/vocabularies/core/uuid> \"42b8b36b-3689-4e7c-bf0a-9d5a29a2285f\" ;
   <http://mu.semte.ch/vocabularies/ext/isPrimitive> true;
   <http://mu.semte.ch/vocabularies/ext/rdfaType> <http://www.w3.org/2001/XMLSchema#dateTime>;
   <http://www.w3.org/2000/01/rdf-schema#label> \"datetime\" .

   # TODO: needs custom handler
   <http://data.lblod.info/id/rdfs-classes/primitive/url> a <http://www.w3.org/2000/01/rdf-schema#Class>;
   <http://mu.semte.ch/vocabularies/core/uuid> \"5149a577-dfd5-4295-8034-4bac01d5ddd7\" ;
   <http://mu.semte.ch/vocabularies/ext/isPrimitive> true;
   <http://mu.semte.ch/vocabularies/ext/rdfaType> <http://www.w3.org/2001/XMLSchema#string>;
   <http://www.w3.org/2000/01/rdf-schema#label> \"url\" .

   # TODO: needs custom handler
   <http://data.lblod.info/id/rdfs-classes/primitive/uri-set> a <http://www.w3.org/2000/01/rdf-schema#Class>;
   <http://mu.semte.ch/vocabularies/core/uuid> \"ef783fd9-2330-4809-b8da-d1b7664f9860\" ;
   <http://mu.semte.ch/vocabularies/ext/isPrimitive> true;
   <http://mu.semte.ch/vocabularies/ext/rdfaType> <http://www.w3.org/2001/XMLSchema#string>;
   <http://www.w3.org/2000/01/rdf-schema#label> \"uri-set\" .

   # TODO: needs custom handler?
   <http://data.lblod.info/id/rdfs-classes/primitive/string-set> a <http://www.w3.org/2000/01/rdf-schema#Class>;
   <http://mu.semte.ch/vocabularies/core/uuid> \"8c4ed73f-5da3-40fd-bbf5-f97caf04f833\" ;
   <http://mu.semte.ch/vocabularies/ext/isPrimitive> true;
   <http://mu.semte.ch/vocabularies/ext/rdfaType> <http://www.w3.org/2001/XMLSchema#string>;
   <http://www.w3.org/2000/01/rdf-schema#label> \"string-set\" .

   # TODO: needs custom handler
   <http://data.lblod.info/id/rdfs-classes/primitive/language-string> a <http://www.w3.org/2000/01/rdf-schema#Class>;
   <http://mu.semte.ch/vocabularies/core/uuid> \"333f8b0a-2443-4eae-8bd0-2b1c67f35e39\" ;
   <http://mu.semte.ch/vocabularies/ext/isPrimitive> true;
   <http://mu.semte.ch/vocabularies/ext/rdfaType> <http://www.w3.org/2001/XMLSchema#string>;
   <http://www.w3.org/2000/01/rdf-schema#label> \"language-string\" .

   # TODO: needs custom handler?
   <http://data.lblod.info/id/rdfs-classes/primitive/language-string-set> a <http://www.w3.org/2000/01/rdf-schema#Class>;
   <http://mu.semte.ch/vocabularies/core/uuid> \"723f2b5d-f0ce-4e1d-948d-b1039e477b0b\" ;
   <http://mu.semte.ch/vocabularies/ext/isPrimitive> true;
   <http://mu.semte.ch/vocabularies/ext/rdfaType> <http://www.w3.org/2001/XMLSchema#string>;
   <http://www.w3.org/2000/01/rdf-schema#label> \"language-string-set\" .

   <http://data.lblod.info/id/rdfs-classes/primitive/g-year> a <http://www.w3.org/2000/01/rdf-schema#Class>;
   <http://mu.semte.ch/vocabularies/core/uuid> \"efed70be-354b-4690-abd7-4dda0fc7306f\" ;
   <http://mu.semte.ch/vocabularies/ext/isPrimitive> true;
   <http://mu.semte.ch/vocabularies/ext/rdfaType> <http://www.w3.org/2001/XMLSchema#gYear>;
   <http://www.w3.org/2000/01/rdf-schema#label> \"g-year\" .

   <http://data.lblod.info/id/rdfs-classes/primitive/geometry> a <http://www.w3.org/2000/01/rdf-schema#Class>;
   <http://mu.semte.ch/vocabularies/core/uuid> \"2f5abaa8-07e3-463e-ab04-3babdbe7c1dd\" ;
   <http://mu.semte.ch/vocabularies/ext/isPrimitive> true;
   <http://mu.semte.ch/vocabularies/ext/rdfaType> <http://www.opengis.net/ont/geosparql#wktLiteral>;
   <http://www.w3.org/2000/01/rdf-schema#label> \"geometry\" .
"
;;   Old statements
;;   "<http://data.lblod.info/id/rdfs-classes/3c7f297e-9c7f-11e8-b70d-ef9004a24187> a <http://www.w3.org/2000/01/rdf-schema#Class>;
;;    <http://mu.semte.ch/vocabularies/core/uuid> \"3c7f297e-9c7f-11e8-b70d-ef9004a24187\" ;
;;    <http://mu.semte.ch/vocabularies/ext/isPrimitive> true;
;;    <http://mu.semte.ch/vocabularies/ext/rdfaType> <http://www.w3.org/2001/XMLSchema#string>;
;;    <http://www.w3.org/2000/01/rdf-schema#label> \"string\" .

;; <http://data.lblod.info/id/rdfs-classes/14e78c54-9fc1-11e8-bf5e-db898e1438d3> a <http://www.w3.org/2000/01/rdf-schema#Class>;
;;    <http://mu.semte.ch/vocabularies/core/uuid> \"14e78c54-9fc1-11e8-bf5e-db898e1438d3\" ;
;;    <http://mu.semte.ch/vocabularies/ext/isPrimitive> true;
;;    <http://mu.semte.ch/vocabularies/ext/rdfaType> <http://www.w3.org/2001/XMLSchema#number>;
;;    <http://www.w3.org/2000/01/rdf-schema#label> \"number\" .

;; <http://data.lblod.info/id/rdfs-classess/79d6c20c-9efd-11e8-ad07-536338a5cf8b> a <http://www.w3.org/2000/01/rdf-schema#Class>;
;;    <http://mu.semte.ch/vocabularies/core/uuid> \"79d6c20c-9efd-11e8-ad07-536338a5cf8b\" ;
;;    <http://mu.semte.ch/vocabularies/ext/isPrimitive> true;
;;    <http://mu.semte.ch/vocabularies/ext/rdfaType> <http://www.w3.org/2001/XMLSchema#datetime>;
;; <http://www.w3.org/2000/01/rdf-schema#label> \"datetime\" .
;; "
  )

(defun all-resources ()
  (loop for val being
     the hash-values of mu-cl-resources::*resources*
     collect val))

(defun generate-resource (resource-instance all-resources)
  "Returns the generator for the specific resource"
  ;; TODO: generate the output for a specific resource.
  (let* ((resource (resource resource-instance))
         (class-uuid (resource-uuid resource-instance))
         (class-uri (resource-uri resource-instance))
         (resource-name (gen-resource-name resource))
         (display-properties (format nil "[~{\\\"~A\\\"~^,~}]"
                                     (resource-properties-as-strings resource)))
         (json-api-type (mu-cl-resources::request-path resource))
         (api-path (format nil "/~A" json-api-type))
         (base-uri (mu-support::raw-content (mu-cl-resources::ld-resource-base resource)))
         (rdfa-type (mu-cl-resources::expanded-ld-class resource))
         (properties (mapcar (lambda (slot) (make-instance 'ld-property-instance :slot slot))
                             (mu-cl-resources::ld-properties resource)))
         (relationships (loop for link in (mu-cl-resources::all-links resource)
                           ;; TODO should we ignore the inverse relationships?
                           unless (mu-cl-resources::inverse-p link) 
                           collect
                             (make-instance 'ld-relation-instance :link link)))
         (property-uris (mapcar #'property-uri properties))
         (relationship-uris (mapcar #'relation-uri relationships)))
    (let ((ttl-resource
           (format nil "~A a <http://www.w3.org/2000/01/rdf-schema#Class>;
   ~T<http://mu.semte.ch/vocabularies/core/uuid> \"~A\" ;
   ~T<http://www.w3.org/2000/01/rdf-schema#label> \"~A\";
   ~T<http://mu.semte.ch/vocabularies/ext/apiPath> \"~A\";
   ~T<http://mu.semte.ch/vocabularies/ext/displayProperties> \"~A\";
   ~T<http://mu.semte.ch/vocabularies/ext/baseUri> \"~A\";
   ~T<http://mu.semte.ch/vocabularies/ext/jsonApiType> \"~A\";
   ~T<http://mu.semte.ch/vocabularies/ext/apiFilter> \"filter\"; # use filter[name] to search on the name property
   ~T<http://mu.semte.ch/vocabularies/ext/isPrimitive> false;
   ~{~T<http://mu.semte.ch/vocabularies/ext/rdfsClassProperties> ~A;~%~}
   ~{~T<http://mu.semte.ch/vocabularies/ext/rdfsClassProperties> ~A;~%~}
   ~T<http://mu.semte.ch/vocabularies/ext/rdfaType> ~A.~%"
                   class-uri class-uuid
                   resource-name
                   api-path
                   display-properties
                   base-uri
                   json-api-type
                   property-uris
                   relationship-uris
                   rdfa-type))
          (ttl-properties
           (mapcar (lambda (property-instance)
                     ;; TODO: cope with inverse properties
                     (let ((slot (resource-slot property-instance)))
                       (format nil
                               "~A a <http://www.w3.org/2000/01/rdf-schema#Property>;
                             <http://mu.semte.ch/vocabularies/core/uuid> \"~A\" ;
                             <http://www.w3.org/2000/01/rdf-schema#label> \"~A\";
                             <http://mu.semte.ch/vocabularies/ext/rdfaType> ~A;
                             <http://www.w3.org/2000/01/rdf-schema#range> <~A>.~%"
                               (property-uri property-instance)
                               (property-uuid property-instance)
                               (string-downcase
                                (mu-cl-resources::symbol-name
                                 (mu-cl-resources::json-key slot)))
                               (mu-support:full-uri (mu-cl-resources::ld-property slot))
                               (format nil "http://data.lblod.info/id/rdfs-classes/primitive/~A"
                                       (string-downcase (symbol-name (mu-cl-resources::resource-type slot)))))))
                   properties))
          (ttl-relationships
           (mapcar (lambda (relationship)
                     (let ((link (link relationship)))
                       (format nil
                               "~A a <http://www.w3.org/2000/01/rdf-schema#Property>;
                             <http://mu.semte.ch/vocabularies/core/uuid> \"~A\" ;
                             <http://www.w3.org/2000/01/rdf-schema#label> \"~A\";
                             <http://mu.semte.ch/vocabularies/ext/rdfaType> ~A;
                             <http://www.w3.org/2000/01/rdf-schema#range> ~A.~%"
                               (relation-uri relationship)
                               (relation-uuid relationship)
                               (mu-cl-resources::json-key link)
                               (mu-support:full-uri (mu-cl-resources::ld-link link))
                               (resource-uri
                                (gethash (mu-cl-resources::find-resource-by-name
                                          (mu-cl-resources::resource-name link))
                                         all-resources)))))
                   relationships)))
      (format nil "# Class for ~A #~%~A~%# Properties for ~A #~%~{~A~^~%~}~%# Relations for ~A #~%~{~A~^~%~}~2%"
              resource-name
              ttl-resource
              resource-name
              ttl-properties
              resource-name
              ttl-relationships)))


  ;; (format nil "edi ember g mu-resource ~A ~{~A ~}~{~A:belongsTo ~}~{~A:hasMany~,^ ~}"
  ;;         (gen-resource-name resource)
  ;;         (mapcar #'gen-resource-slot (mu-cl-resources::ld-properties resource))
  ;;         (mapcar #'mu-cl-resources::request-path (mu-cl-resources::has-one-links resource))
  ;;         (mapcar #'mu-cl-resources::request-path (mu-cl-resources::has-many-links resource)))
  )

(defun gen-resource-name (resource)
  (string-downcase (mu-cl-resources::resource-name resource)))

(defun resource-properties-as-strings (resource)
  "Yields the string representation of the properties of the supplied
   resource."
  (mapcar (lambda (property) (mu-cl-resources::json-property-name property))
          (mu-cl-resources::ld-properties resource)))

;; (defun gen-resource-slot (property)
;;   (format nil "~A:~A"
;;           (string-downcase (symbol-name (mu-cl-resources::json-key property)))
;;           (string-downcase (symbol-name (mu-cl-resources::resource-type property)))))
