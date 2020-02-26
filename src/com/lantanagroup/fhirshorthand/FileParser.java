/*

Copyright 2020 Lantana Consulting Group


Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. 

*/

package com.lantanagroup.fhirshorthand;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.UnsupportedEncodingException;

import org.hl7.fhir.instance.model.api.IBaseResource;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.Resource;
import org.hl7.fhir.r4.model.StructureDefinition;

import com.google.common.io.Files;

import ca.uhn.fhir.context.FhirContext;
import ca.uhn.fhir.parser.DataFormatException;
import ca.uhn.fhir.parser.JsonParser;
import ca.uhn.fhir.parser.XmlParser;

public class FileParser {
	
	private final FhirContext ctx = FhirContext.forR4();
	private XmlParser xmlParser = (XmlParser) ctx.newXmlParser();
	private JsonParser jsonParser = (JsonParser) ctx.newJsonParser();
	
	public Resource parse (File f) throws FileNotFoundException {
		Resource res = null;
		FileReader fr = new FileReader(f);
		String ext = Files.getFileExtension(f.getName().toLowerCase());
		if (ext.equals("xml")) {
			res = (Resource)xmlParser.parseResource(fr);
		} else if (ext.equals("json")) {
			res = (Resource)jsonParser.parseResource(fr);
		} else {
			// Neither extension recognized, try XML first, then JSON, then fail
			try {
				res = (Resource)xmlParser.parseResource(fr);
			} catch (DataFormatException e) {
				res = (Resource)jsonParser.parseResource(fr);
			}
		}
		System.err.println(f.getName() + " is a " + res.fhirType());
		if (res.hasId() == false) {
			res.setId(Files.getNameWithoutExtension(f.getName()));
		}
		return res;
	}
	
	public File serializeXml(File outFolder, String fileName, Resource res) throws IOException {
		String xmlStr = xmlParser.encodeResourceToString(res);
		byte[] myBytes = xmlStr.getBytes("UTF-8");
		File f = new File(outFolder, fileName);
        FileWriter fw = new FileWriter(f);
        fw.write(xmlStr);
        fw.close();
        return f;
	}
	

}
