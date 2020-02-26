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
import java.io.FileWriter;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.hl7.fhir.instance.model.api.IBaseResource;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.Bundle.BundleEntryComponent;
import org.hl7.fhir.r4.model.Resource;
import org.hl7.fhir.r4.model.StructureDefinition;
import org.hl7.fhir.r4.conformance.ProfileUtilities; // has a generateSnapshot method

import com.google.common.io.Files;

/**
 * @author rickg
 *
 */
public class FshFood {
	
	private static final String OUT_FOLDER = "outFolder";
	private static final String TEMP_FOLDER = "tempFolder";
	private static final String IN_FILE = "inFile";
	


	private File inFile;
	private File tempFolder;
	private File outFolder;
	private ArrayList<File> foodFiles = new ArrayList<File>();
	private FshTransformer ft;
	

	public static void main(String[] args) {
		System.out.println("Opening FSH Food");
		Options options = new Options();
		options.addOption(IN_FILE, true, "Input file");
		options.addOption(TEMP_FOLDER, true, "Temp folder");
		options.addOption(OUT_FOLDER, true, "Output folder");
		CommandLineParser parser = new DefaultParser();
		CommandLine cmd;
		try {
			cmd = parser.parse( options, args);
			File tempFolder;
			if (cmd.hasOption(TEMP_FOLDER)) {
				tempFolder = new File(cmd.getOptionValue(TEMP_FOLDER));
			} else {
				tempFolder = Files.createTempDir();
				System.out.println("Temp Dir: " + tempFolder.getAbsolutePath());
			}
			FshFood fd = new FshFood(
						new File(cmd.getOptionValue(IN_FILE)), 
						tempFolder, 
						new File(cmd.getOptionValue(OUT_FOLDER))
					);
			fd.normalizeInput();
			ArrayList<File> fshFiles = fd.feedFsh();
			System.out.println("Generated FSH files: " + fshFiles.size());
			for (File f: fshFiles) {
				System.out.println(f.getAbsolutePath());
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	


	public FshFood(File inFile, File tempFolder, File outFolder) throws TransformerConfigurationException {
		this.inFile = inFile;
		this.tempFolder = tempFolder;
		this.outFolder = outFolder;
		if (outFolder.exists() == false) {
			outFolder.mkdirs();
		}
		ft = new FshTransformer();
	}
	
	
	/**
	 * Parses the inputFile in either FHIR JSON or XML serializes it as XML into the temp directory. If the input file is a StructureDefinition that's it. If it is a Bundle then it serializes each StructureDefinition in the Bundle into a separate file. 
	 * @throws IOException
	 * @throws URISyntaxException
	 */
	public void normalizeInput()  throws IOException, URISyntaxException {
		FileParser fp = new FileParser();
		Resource res = fp.parse(inFile);
		processResource(fp, Files.getNameWithoutExtension(inFile.getName()) + ".xml", res);
		System.out.println("Processable files: " + foodFiles.size());
	}

	private void processResource(FileParser fp, String targetFileName, Resource res) throws IOException, URISyntaxException {
		if (res.fhirType().equals("StructureDefinition")) {
			StructureDefinition sd = (StructureDefinition) res;
			if (sd.hasSnapshot() == false) {
				System.err.println(targetFileName + " has no snapshot and may fail to create valid FSH.");
			}
			File f = fp.serializeXml(tempFolder, targetFileName , sd);
			foodFiles.add(f);
		} else if (res.fhirType().equals("Bundle")) {
			Bundle b = (Bundle)res;
			List<BundleEntryComponent> entries = b.getEntry();
			for (BundleEntryComponent entry: entries) {
				String urlStr = entry.getFullUrl();
				URL fullUrl = new URI(urlStr).toURL();
				Resource entryRes = entry.getResource();
				String fileName = Files.getNameWithoutExtension(fullUrl.getFile()) + ".xml";
				processResource(fp,fileName,entryRes);
			}
		}
	}

	public ArrayList<File> feedFsh() throws TransformerException, IOException {
		ArrayList<File> fshFiles = new ArrayList<File>();
		for (File food: foodFiles) {
			String fsh = ft.foodToFsh(food);
			File fshFile = new File(this.outFolder,Files.getNameWithoutExtension(food.getName()) + ".fsh");
			FileWriter fw = new FileWriter(fshFile);
			fw.write(fsh);
			fw.close();
			fshFiles.add(fshFile);
		}
		return fshFiles;
	}



}
