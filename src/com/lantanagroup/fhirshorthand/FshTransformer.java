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

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.InputStream;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

public class FshTransformer {
	
	private StreamSource fshStream;
	private Transformer feeder;
	
	public FshTransformer() throws TransformerConfigurationException {
		InputStream in = getClass().getResourceAsStream("/fshfood.xslt"); 
		fshStream = new StreamSource(in);
		TransformerFactory tf = TransformerFactory.newInstance();
		feeder = tf.newTransformer(fshStream);
	}
	
	public String foodToFsh (File food) throws TransformerException {
		StreamSource foodSource = new StreamSource(food);
		ByteArrayOutputStream bout = new ByteArrayOutputStream();
		StreamResult fedFsh = new StreamResult(bout);
		feeder.transform(foodSource, fedFsh);
		return new String(bout.toByteArray());
	}

}
