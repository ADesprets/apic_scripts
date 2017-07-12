package com.ibm.ad.swagger;

import java.io.File;
import java.io.IOException;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.JsonMappingException;

import io.swagger.models.Swagger;
import io.swagger.util.Json;

public class MyTest {

	public static void main(String[] args) {
		System.out.println("Test de-serialisation parsing Swagger file");
		try {
			File sf = new File(
					"D:\\CurrentProjects\\APIMgt\\Technical\\swagger-core\\modules\\swagger-core\\src\\test\\resources\\QuoteManagement.json");
			final Swagger swagger = Json.mapper().readValue(sf, Swagger.class);

			String info = null;

			info = swagger.getInfo().getContact().getName();
			printInfo("Contact name", info);
			info = swagger.getInfo().getContact().getEmail();
			printInfo("email", info);
			info = swagger.getInfo().getContact().getUrl();
			printInfo("url", info);

			info = swagger.getInfo().getTermsOfService();
			printInfo("Terms of service", info);

		} catch (JsonParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (JsonMappingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	private static void printInfo(String description, String info) {
		if (info != null) {
			System.out.println(description + ": " + info);
		}
	}
}
