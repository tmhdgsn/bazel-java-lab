package subtool;

import invokable.Invokable;


import com.google.devtools.build.runfiles.Runfiles;

import java.nio.file.Path;
import java.nio.file.Files;

public class Subtool implements Invokable {
	@Override
	public void invoke(String output) {
		try {
			Runfiles runfiles = Runfiles.create();
			String path = runfiles.rlocation("my_workspace/subtool/foo.yaml");

			byte[] allBytes = Files.readAllBytes(Path.of(path));

			Files.write(Path.of(output), allBytes);
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

}
