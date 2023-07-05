public class FileCopyResponse {

	public class Path_collection {
		public Integer total_count;
		public List<Entries> entries;
	}

	public class File_version {
		public String type;
		public String id;
		public String sha1;
	}

	public class Parent {
		public String type;
		public String id;
		public String sequence_id;
		public String etag;
		public String name;
	}

	public String type;
	public String id;
	public File_version file_version;
	public String sequence_id;
	public String etag;
	public String sha1;
	public String name;
	public String description;
	public Integer size;
	public Path_collection path_collection;
	public String created_at;
	public String modified_at;
	public String trashed_at;
	public String purged_at;
	public String content_created_at;
	public String content_modified_at;
	public Created_by created_by;
	public Created_by modified_by;
	public Created_by owned_by;
	public String shared_link;
	public Parent parent;
	public String item_status;

	public class Entries {
		public String type;
		public String id;
		public String sequence_id;
		public String etag;
		public String name;
	}

	public class Created_by {
		public String type;
		public String id;
		public String name;
		public String login;
	}

	
	public static FileCopyResponse parse(String json) {
		return (FileCopyResponse) System.JSON.deserialize(json, FileCopyResponse.class);
	}
}