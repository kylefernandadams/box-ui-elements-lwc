public class UserResponse {

	public String id;
	public String type;
	public String login;
	public String name;

	
	public static UserResponse parse(String json) {
		return (UserResponse) System.JSON.deserialize(json, UserResponse.class);
	}
}