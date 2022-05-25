package invoker;

import invokable.Invokable;

public class Invoker {
	public static void main(String[] args) throws Exception {
		String className = args[0];
		String output = args[1];
		Class clazz = Class.forName(className);
		Object instanceOfSubtool = clazz.getDeclaredConstructor().newInstance();

		System.out.println("invoker");
		Invokable invokable = (Invokable) instanceOfSubtool;
		invokable.invoke(output);
	}
}
