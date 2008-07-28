class Projects < Application
  provides :xml, :yaml, :js

  def index
    @projects = Project.all
    display @projects
  end

  def show
    @project = Project.get(params[:id])
    raise NotFound unless @project
    display @project
  end

  def new
    only_provides :html
    @project = Project.new
    render
  end

  def edit
    only_provides :html
    @project = Project.get(params[:id])
    raise NotFound unless @project
    render
  end

  def create
    @project = Project.new(params[:project])
    if @project.save
      redirect url(:project, @project)
    else
      render :new
    end
  end

  def update
    @project = Project.get(params[:id])
    raise NotFound unless @project
    if @project.update_attributes(params[:project]) || !@project.dirty?
      redirect url(:project, @project)
    else
      raise BadRequest
    end
  end

  def destroy
    @project = Project.get(params[:id])
    raise NotFound unless @project
    if @project.destroy
      redirect url(:project)
    else
      raise BadRequest
    end
  end

end
