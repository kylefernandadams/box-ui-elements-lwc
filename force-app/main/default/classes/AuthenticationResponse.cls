public class AuthenticationResponse {

	public class Restricted_to {
		public String scope {get;set;} 
		public BoxItem boxItem {get;set;} // in json: object

		public Restricted_to(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'scope') {
							scope = parser.getText();
						} else if (text == 'object') {
							boxItem = new BoxItem(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Restricted_to consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class File_version {
		public String id {get;set;} 
		public String type {get;set;} 
		public String sha1 {get;set;} 

		public File_version(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'type') {
							type = parser.getText();
						} else if (text == 'sha1') {
							sha1 = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'File_version consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class BoxItem {
		public String id {get;set;} 
		public String etag {get;set;} 
		public String type {get;set;} 
		public String sequence_id {get;set;} 
		public String name {get;set;} 
		public String sha1 {get;set;} 
		public File_version file_version {get;set;} 

		public BoxItem(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'etag') {
							etag = parser.getText();
						} else if (text == 'type') {
							type = parser.getText();
						} else if (text == 'sequence_id') {
							sequence_id = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'sha1') {
							sha1 = parser.getText();
						} else if (text == 'file_version') {
							file_version = new File_version(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Object_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public String access_token {get;set;} 
	public Integer expires_in {get;set;} 
	public String issued_token_type {get;set;} 
	public String refresh_token {get;set;} 
	public List<Restricted_to> restricted_to {get;set;} 
	public String token_type {get;set;} 

	public AuthenticationResponse(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'access_token') {
						access_token = parser.getText();
					} else if (text == 'expires_in') {
						expires_in = parser.getIntegerValue();
					} else if (text == 'issued_token_type') {
						issued_token_type = parser.getText();
					} else if (text == 'refresh_token') {
						refresh_token = parser.getText();
					} else if (text == 'restricted_to') {
						restricted_to = arrayOfRestricted_to(parser);
					} else if (text == 'token_type') {
						token_type = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'AuthenticationResponse consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static AuthenticationResponse parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new AuthenticationResponse(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	


    private static List<Restricted_to> arrayOfRestricted_to(System.JSONParser p) {
        List<Restricted_to> res = new List<Restricted_to>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Restricted_to(p));
        }
        return res;
    }
}