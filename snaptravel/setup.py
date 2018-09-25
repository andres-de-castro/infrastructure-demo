from setuptools import setup

setup(
    name='Snaptravel-CLI',
    version='1.0',
    packages=['cli', 'cli.commands'],
    install_requires=[
        'click',
    ],    
    include_package_data=True,
    entry_points="""
        [console_scripts]
        snaptravel=cli.cli:cli
    """,
)
