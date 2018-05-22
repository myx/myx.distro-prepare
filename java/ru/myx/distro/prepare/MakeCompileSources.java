package ru.myx.distro.prepare;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class MakeCompileSources {

    public static void main(final String[] args) throws Exception {
	if (args.length < 2) {
	    System.err.println(MakeCompileSources.class.getSimpleName() + ": 'source-root' 'output-root'");
	    Runtime.getRuntime().exit(-1);
	    return;
	}

	final Path sourceRoot = Paths.get(args[0]);
	if (!Files.isDirectory(sourceRoot)) {
	    System.err.println(
		    MakeCompileSources.class.getSimpleName() + ": source-root is not a directory: " + sourceRoot);
	    Runtime.getRuntime().exit(-2);
	    return;
	}

	final Path outputRoot = Paths.get(args[1]);
	if (!Files.isDirectory(outputRoot)) {
	    System.err.println(MakeCompileSources.class.getSimpleName() + ": output-root is not a directory");
	    Runtime.getRuntime().exit(-3);
	    return;
	}

	final Distro repositories = new Distro();
	repositories.buildPrepareIndexFromSource(outputRoot, sourceRoot);

	final MakeCompileJava javaCompiler = new MakeCompileJava(sourceRoot, outputRoot);

	// repositories.loadFromLocalIndex(outputRoot.resolve("distro"));
	for (int i = 2; i < args.length; ++i) {
	    final String arg = args[i];
	    if ("--from-output".equals(arg)) {
		javaCompiler.sourcesFromOutput = true;
		continue;
	    }
	    if ("--all".equals(arg)) {
		repositories.compileAllJavaSource(javaCompiler);
		continue;
	    }
	    if ("--repository".equals(arg)) {
		if (++i >= args.length) {
		    throw new IllegalArgumentException("repository is expected for --repository agrument");
		}
		final Repository repo = repositories.getRepository(args[i]);
		if (repo == null) {
		    throw new IllegalArgumentException("repository is unknown, name: " + args[i]);
		}
		repo.compileAllJavaSource(javaCompiler);
		continue;
	    }
	    if ("--project".equals(arg)) {
		if (++i >= args.length) {
		    throw new IllegalArgumentException("project is expected for --project agrument");
		}
		final Project proj = repositories.getProject(args[i]);
		if (proj == null) {
		    throw new IllegalArgumentException("project is unknown, name: " + args[i]);
		}
		proj.compileAllJavaSource(javaCompiler);
		continue;
	    }
	}
    }

}
