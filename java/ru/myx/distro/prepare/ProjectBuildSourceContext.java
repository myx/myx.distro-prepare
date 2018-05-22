package ru.myx.distro.prepare;

import java.nio.file.Path;

class ProjectBuildSourceContext {
    public final Path cached;
    public final Path distro;

    public final Project project;

    public final RepositoryBuildSourceContext repository;

    public final Path source;

    ProjectBuildSourceContext(final Project project, final RepositoryBuildSourceContext repository) {
	this.project = project;
	this.repository = repository;
	this.source = repository.source.resolve(project.name);
	this.distro = repository.distro.resolve(project.name);
	this.cached = repository.cached.resolve(project.name);
    }
}