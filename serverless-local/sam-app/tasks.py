from invoke import task


@task
def package(c):
    print('This is package job')
    c.run('pip install -U -r requirements.txt -t hello_world/build/')
    c.run('cp hello_world/*.py hello_world/build/')
    pass
