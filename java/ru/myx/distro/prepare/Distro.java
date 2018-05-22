package ru.myx.distro.prepare;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import ru.myx.distro.ClasspathBuilder;
import ru.myx.distro.Utils;

public final class Distro {
    private final Map<String, Project> byProjectName = new HashMap<>();

    private final Map<String, Repository> byRepositoryName = new HashMap<>();

    private final List<Project> sequenceProjects = new ArrayList<>();

    private final List<Repository> sequenceRepositories = new ArrayList<>();

    public Distro() {
	//
    }

    boolean addKnown(final Repository repo) {
	this.byRepositoryName.put(repo.getName(), repo);
	return true;
    }

    boolean addSequence(final Project project) {
	if (this.sequenceProjects.contains(project)) {
	    return false;
	}
	this.sequenceProjects.add(project);
	return true;
    }

    boolean addSequence(final Repository repo) {
	if (this.sequenceRepositories.contains(repo)) {
	    return false;
	}
	this.sequenceRepositories.add(repo);
	return true;
    }

    public boolean buildCalculateSequence() {
	this.sequenceRepositories.clear();
	this.sequenceProjects.clear();
	for (final Repository repository : this.byRepositoryName.values()) {
	    repository.buildCalculateSequence(this, new HashMap<>());
	}
	// sorted used repositories
	for (final Project project : this.sequenceProjects) {
	    this.addSequence(project.repo);
	}
	// empty unsorted then
	for (final Repository repository : this.byRepositoryName.values()) {
	    this.addSequence(repository);
	}
	return true;
    }

    public void buildPrepareCompileIndex(final ConsoleOutput console, final Path outputTarget) throws Exception {
	this.buildPrepareDistroIndex(console, outputTarget, false);

	{
	    final Properties info = new Properties();
	    {
		final StringBuilder builder = new StringBuilder(256);
		for (final Repository repository : this.sequenceRepositories) {
		    builder.append(repository.name).append(' ');
		    info.setProperty("REP-" + repository.name.trim(), repository.fetch.trim());
		}
		info.setProperty("REPS", builder.toString().trim());
	    }
	    {
		final StringBuilder builder = new StringBuilder(256);
		for (final Project project : this.sequenceProjects) {
		    builder.append(project.repo.name).append('/').append(project.name).append(' ');
		    project.buildPrepareDistroIndexFillProjectInfo(info);
		}
		info.setProperty("PRJS", builder.toString().trim());
	    }
	    {
		final Map<String, Set<Project>> provides = this.getProvides();
		for (final String provide : provides.keySet()) {
		    final StringBuilder builder = new StringBuilder(256);
		    for (final Project project : provides.get(provide)) {
			builder.append(project.repo.name).append('/').append(project.name).append(' ');
		    }
		    info.setProperty("PRV-" + provide, builder.toString().trim());
		}
	    }

	    Utils.save(//
		    console, //
		    outputTarget.resolve("distro-index.inf"), //
		    info, //
		    "Generated by ru.myx.distro.prepare", //
		    true//
	    );
	}

	final List<String> compileJava = new ArrayList<>();
	final ClasspathBuilder classpath = new ClasspathBuilder();

	for (final Repository repo : this.sequenceRepositories) {
	    repo.buildPrepareCompileIndex(console, this, outputTarget.resolve(repo.name), compileJava);
	    repo.buildPrepareCompileIndexMakeClasspath(classpath);
	}

	Files.write(//
		outputTarget.resolve("distro-classpath.txt"), //
		classpath);
    }

    public void buildPrepareDistroIndex(final ConsoleOutput console, final Path outputTarget, final boolean deep)
	    throws Exception {
	if (!Files.isDirectory(outputTarget)) {
	    throw new IllegalStateException("outputTarget is not a folder, " + outputTarget);
	}

	{
	    final List<String> repositoryNames = new ArrayList<>();
	    {
		for (final Repository repo : this.sequenceRepositories) {
		    repositoryNames.add(repo.getName());
		}
	    }

	    Files.write(outputTarget.resolve("repository-names.txt"), repositoryNames, StandardCharsets.UTF_8);
	}

	if (deep) {
	    for (final Repository repo : this.sequenceRepositories) {
		repo.buildPrepareDistroIndex(console, this, outputTarget.resolve(repo.name), true);
	    }
	}
    }

    public boolean buildPrepareIndexFromSource(final Path outputRoot, final Path sourceRoot) throws Exception {
	final DistroBuildSourceContext ctx = new DistroBuildSourceContext(outputRoot, sourceRoot);
	{
	    for (final Repository repo : this.sequenceRepositories) {
		repo.buildSource(this, ctx);
	    }
	}
	ctx.writeOut();
	return true;
    }

    void compileAllJavaSource(final MakeCompileJava javaCompiler) throws Exception {

	for (final Repository repository : this.byRepositoryName.values()) {
	    repository.compileAllJavaSource(javaCompiler);
	}
    }

    public Project getProject(final String name) {
	final int pos = name.indexOf('/');
	if (pos == -1) {
	    for (final Repository repo : this.byRepositoryName.values()) {
		final Project proj = repo.getProject(name);
		if (proj != null) {
		    return proj;
		}
	    }
	    return null;
	}
	{
	    final String repositoryName = name.substring(0, pos);
	    final Repository repo = this.byRepositoryName.get(repositoryName);
	    if (repo == null) {
		throw new IllegalArgumentException("repository is unknown, name: " + repositoryName);
	    }
	    return repo.getProject(name.substring(pos + 1));
	}
    }

    public Map<String, Set<Project>> getProvides() {
	final Map<String, Set<Project>> result = new HashMap<>();
	for (final Repository repository : this.byRepositoryName.values()) {
	    final Map<String, Set<Project>> provides = repository.getProvides();
	    for (final String provide : provides.keySet()) {
		Set<Project> set = result.get(provide);
		if (set == null) {
		    set = new HashSet<>();
		    result.put(provide, set);
		}
		set.addAll(provides.get(provide));
	    }
	}
	return result;
    }

    public Set<Project> getProvides(final OptionListItem name) {
	Set<Project> set = null;
	for (final Repository repository : this.byRepositoryName.values()) {
	    final Set<Project> provides = repository.getProvides(name);
	    if (provides == null) {
		continue;
	    }
	    for (final Project provide : provides) {
		if (set == null) {
		    set = new HashSet<>();
		}
		set.add(provide);
	    }
	}
	return set;
    }

    public Iterable<Repository> getRepositories() {
	return this.byRepositoryName.values();
    }

    public Repository getRepository(final String name) {
	return this.byRepositoryName.get(name);
    }

    public Iterable<Project> getSequenceProjects() {
	return this.sequenceProjects;
    }

    public void reset() {
	this.byRepositoryName.clear();
	this.sequenceRepositories.clear();
	this.byProjectName.clear();
	this.sequenceProjects.clear();
    }
}
