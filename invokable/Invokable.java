package invokable;

public interface Invokable {
	default void invoke(String output) throws Exception {
		System.out.println("override me");
	}
}
