public class FileCopyRequest {
    public Parent parent;

	public class Parent {
		public String id;
	}

	
	public static FileCopyRequest parse(String json) {
		return (FileCopyRequest) System.JSON.deserialize(json, FileCopyRequest.class);
	}
}
