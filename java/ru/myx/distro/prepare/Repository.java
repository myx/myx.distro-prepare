package ru.myx.distro.prepare;

import java.io.InputStream;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.stream.Stream;

import ru.myx.distro.ClasspathBuilder;
import ru.myx.distro.Utils;

public class Repository {

    public static boolean checkIfRepository(final Path repositoryRoot) throws Exception {
	final Path infPath = repositoryRoot.resolve("repository.inf");
	if (!Files.isRegularFile(infPath)) {
	    return false;
	}
	return true;
    }

    public static Repository staticLoadFromLocalIndex(final Distro repos, final Path repositoryRoot) throws Exception {
	final Path infPath = repositoryRoot.resolve("repository.inf");
	if (!Files.isRegularFile(infPath)) {
	    // doesn't have a manifest
	    throw new IllegalStateException();
	}
	final Properties info = new Properties();
	try (final InputStream in = Files.newInputStream(infPath)) {
	    info.load(in);
	}
	final String repositoryName = repositoryRoot.getFileName().toString();
	final String fetch = info.getProperty("Fetch", "").trim();
	return new Repository(repositoryName, fetch.length() == 0 ? null : fetch, repos);
    }

    public static Repository staticLoadFromLocalSource(final Distro repos, final Path repositoryRoot) throws Exception {
	final String repositoryName = repositoryRoot.getFileName().toString();
	final Path infPath = repositoryRoot.resolve("repository.inf");
	if (!Files.isRegularFile(infPath)) {
	    // doesn't have a manifest
	    return null;
	}
	final Properties info = new Properties();
	try (final InputStream in = Files.newInputStream(infPath)) {
	    info.load(in);
	}
	final String name = info.getProperty("Name", "").trim();
	if (name.length() == 0) {
	    // 'Name' is mandatory
	    System.err.println(Repository.class.getSimpleName() + ": skipped, no 'Name' in repository.inf");
	    return null;
	}
	if (!name.equals(repositoryName)) {
	    // 'Name' is mandatory
	    System.err.println(Repository.class.getSimpleName()
		    + ": skipped, 'Name' not equal actual folder name in repository.inf, folder: " + repositoryName);
	    return null;
	}
	final String fetch = info.getProperty("Fetch", "").trim();
	return new Repository(repositoryName, fetch.length() == 0 ? null : fetch, repos);
    }

    private final Map<String, Project> byName = new HashMap<>();

    private final Map<String, Set<Project>> byProvides = new HashMap<>();

    public final String fetch;

    public final String name;

    private final List<Project> sequence = new ArrayList<>();

    public Repository(final String name, final String fetch, final Distro repositories) {
	this.name = name;
	this.fetch = fetch;
	if (repositories != null) {
	    repositories.addKnown(this);
	}
    }

    boolean addKnown(final Project proj) {
	this.byName.put(proj.getName(), proj);
	this.addProvides(proj, new OptionListItem(proj.getName()));
	return true;
    }

    public void addProvides(final Project project, final OptionListItem provides) {
	Set<Project> set = this.byProvides.get(provides.getName());
	if (set == null) {
	    set = new HashSet<>();
	    this.byProvides.put(provides.getName(), set);
	}
	set.add(project);
    }

    boolean addSequence(final Project proj) {
	this.sequence.add(proj);
	return true;
    }

    public void buildCalculateSequence(final Distro repositories, final Map<String, Project> checked) {
	this.sequence.clear();
	for (final Project project : this.byName.values()) {
	    project.buildCalculateSequence(this, repositories, checked);
	}

    }

    public void buildPrepareCompileIndex(final ConsoleOutput console, final Distro repositories,
	    final Path repositoryOutput, final List<String> compileJava) throws Exception {
	this.buildPrepareDistroIndex(console, repositories, repositoryOutput, false);

	for (final Project project : this.sequence) {
	    project.buildPrepareCompileIndex(console, this, repositoryOutput.resolve(project.name), compileJava);
	}

	{
	    Files.write(//
		    repositoryOutput.resolve("repository-classpath.txt"), //
		    this.buildPrepareCompileIndexMakeClasspath(new ClasspathBuilder()));
	}
    }

    public ClasspathBuilder buildPrepareCompileIndexMakeClasspath(final ClasspathBuilder list) {
	for (final Project project : this.sequence) {
	    project.buildPrepareCompileIndexMakeClasspath(list);
	}
	return list;
    }

    public void buildPrepareDistroIndex(final ConsoleOutput console, final Distro repositories,
	    final Path repositoryOutput, final boolean deep) throws Exception {
	Files.createDirectories(repositoryOutput);
	if (!Files.isDirectory(repositoryOutput)) {
	    throw new IllegalStateException("repositoryOutput is not a folder, " + repositoryOutput);
	}

	{
	    final Properties info = new Properties();
	    info.setProperty("Name", this.name);
	    info.setProperty("Fetch", this.fetch);

	    Utils.save(//
		    console, repositoryOutput.resolve("repository.inf"), //
		    info, //
		    "Generated by ru.myx.distro.prepare", //
		    true//
	    );
	}

	{
	    final Stream<String> projectNames = this.sequence.stream().map(Project::projectName);

	    Utils.save(//
		    console, repositoryOutput.resolve("project-names.txt"), //
		    projectNames //
	    );
	}

	{
	    final Properties info = new Properties();
	    {
		info.setProperty("REPO", this.name.trim());
		info.setProperty("REPS", this.name.trim());
		info.setProperty("REP-" + this.name.trim(), this.fetch.trim());
	    }
	    {
		final StringBuilder builder = new StringBuilder(256);
		for (final Project project : this.sequence) {
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
		    repositoryOutput.resolve("repository-index.inf"), //
		    info, //
		    "Generated by ru.myx.distro.prepare", //
		    true//
	    );
	}

	if (deep) {
	    for (final Project project : this.sequence) {
		project.buildPrepareDistroIndex(console, this, repositoryOutput.resolve(project.name), true);
	    }
	}
    }

    public boolean buildSource(final Distro repos, final DistroBuildSourceContext ctx) throws Exception {

	final RepositoryBuildSourceContext repositoryCtx = new RepositoryBuildSourceContext(this, ctx);

	final Path source = repositoryCtx.source;
	if (!Files.isDirectory(source)) {
	    throw new IllegalStateException("source is not a folder, " + source);
	}

	final Path distro = repositoryCtx.distro;
	Files.createDirectories(distro);
	if (!Files.isDirectory(distro)) {
	    throw new IllegalStateException("distro is not a folder, " + distro);
	}

	final Path cached = repositoryCtx.cached;
	Files.createDirectories(cached);
	if (!Files.isDirectory(cached)) {
	    throw new IllegalStateException("cached is not a folder, " + cached);
	}

	{
	    Files.copy(//
		    source.resolve("repository.inf"), //
		    distro.resolve("repository.inf"), //
		    StandardCopyOption.REPLACE_EXISTING);
	}

	{
	    for (final Project pkg : this.getProjectsSequence()) {
		if (!pkg.buildSource(this, repositoryCtx)) {
		    return false;
		}
	    }
	}

	repositoryCtx.writeOut();

	return true;
    }

    void compileAllJavaSource(final MakeCompileJava javaCompiler) throws Exception {

	for (final Project project : this.byName.values()) {
	    project.compileAllJavaSource(javaCompiler);
	}

    }

    @Override
    public boolean equals(final Object obj) {
	if (this == obj) {
	    return true;
	}
	if (obj == null) {
	    return false;
	}
	if (this.getClass() != obj.getClass()) {
	    return false;
	}
	final Repository other = (Repository) obj;
	if (this.name == null) {
	    if (other.name != null) {
		return false;
	    }
	} else if (!this.name.equals(other.name)) {
	    return false;
	}
	return true;
    }

    public String getName() {
	return this.name;
    }

    Project getProject(final String name) {
	return this.byName.get(name);
    }

    public Iterable<Project> getProjects() {
	return this.byName.values();
    }

    public Iterable<Project> getProjectsSequence() {
	return this.sequence;
    }

    public Map<String, Set<Project>> getProvides() {
	final Map<String, Set<Project>> result = new HashMap<>();
	result.putAll(this.byProvides);
	return result;
    }

    public Set<Project> getProvides(final OptionListItem name) {
	return this.byProvides.get(name.getName());
    }

    @Override
    public int hashCode() {
	final int prime = 31;
	int result = 1;
	result = prime * result + (this.name == null ? 0 : this.name.hashCode());
	return result;
    }

    public void loadFromLocalIndex(final Distro repos, final Path repositoryRoot) throws Exception {
	{
	    final Path infoFile = repositoryRoot.resolve("repository-index.inf");
	    if (Files.isRegularFile(infoFile)) {
		final Properties info = new Properties();
		info.load(Files.newBufferedReader(infoFile));

		final String name = info.getProperty("REPO", "");
		if (!this.name.equals(name)) {
		    throw new IllegalStateException(
			    "name from index does not match, repository: " + this.name + ", path=" + infoFile);
		}
		this.loadFromLocalIndex(repos, info);
		return;
	    }
	}
	{
	    for (final String projectName : Files.readAllLines(repositoryRoot.resolve("project-names.txt"))) {
		final Path projectRoot = repositoryRoot.resolve(projectName);
		final Project project = Project.staticLoadFromLocalIndex(this, projectName, projectRoot);
		if (project != null) {
		    project.loadFromLocalIndex(this, projectRoot);
		}
	    }
	}
    }

    public void loadFromLocalIndex(final Distro repos, final Properties info) {
	for (final String projectId : info.getProperty("PRJS", "").split(" ")) {
	    final String projectName = projectId.substring(projectId.indexOf('/') + 1).trim();
	    if (projectName.length() == 0) {
		continue;
	    }
	    final Properties projectInfo = new Properties();
	    projectInfo.setProperty("Name", projectName);
	    final Project project = new Project(projectName, projectInfo, this);
	    project.loadFromLocalIndex(this, info);
	}
    }

    public void loadFromLocalSource(final ConsoleOutput console, final Distro repositories, final Path repositoryRoot)
	    throws Exception {

	this.loadFromLocalSource(console, repositories, repositoryRoot, repositoryRoot);
    }

    public void loadFromLocalSource(final ConsoleOutput console, final Distro repositories, final Path repositoryRoot,
	    final Path currentRoot) throws Exception {

	try (final DirectoryStream<Path> projects = Files.newDirectoryStream(currentRoot)) {

	    for (final Path projectRoot : projects) {

		if (Project.checkIfProject(projectRoot)) {

		    final Project project = Project.staticLoadFromLocalSource(//
			    this, //
			    repositoryRoot.relativize(projectRoot).toString(), //
			    projectRoot//
		    );
		    if (project != null) {
			project.loadFromLocalSource(console, this, projectRoot);
			console.outProgress('p');
		    }
		    continue;

		}

		final String folderName = projectRoot.getFileName().toString();
		if (folderName.length() < 2 || folderName.charAt(0) == '.') {
		    // not a user-folder, hidden
		    continue;
		}
		if (!Files.isDirectory(projectRoot)) {
		    continue;
		}

		this.loadFromLocalSource(console, repositories, repositoryRoot, projectRoot);
	    }
	}
    }

}
