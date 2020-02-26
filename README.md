Main class if FshFood

Takes the following parameters
* -inFile: the input file (either a StructureDefinition or a Bundle that contains StructureDefinition resources)
* -tempFolder: the location of the temporarily folder. If not supplied one will be automatically created (this parameter is optional, just for debugging purposes)
* -outFolder: the output folder where you want the resulting FSH files to be created

The xslt folder must be on the classpath.

This program currently requires that any StructureDefinition provided to it has a StructureDefinition.snapshot fully and accurately populated. However, future versions may either do snapshot generation automatically, or the FHIR Shorthand spec may be fixed to handle partially specified cardinality as is allowed in StructureDefinition.differential (i.e. just a min or max vs. both; would look like "..1" or "0.." vs. requiring "0..1").

If you do not want to use this Java driver and have your own XSLT 2.0 processor, you may run fshfood.xslt directly against a single StructureDefinition with a snapshot. The Java code basically just handles JSON to XML conversion, extracting StructureDefinition resources from Bundles, and invoking the transform. The transform does all the heavy lifting. 