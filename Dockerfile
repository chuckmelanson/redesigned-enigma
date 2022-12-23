FROM jupyter/datascience-notebook:latest

USER root

### BASICS ###
# Technical Environment Variables
ENV \
    SHELL="/bin/bash" \
    # HOME="/root"  \
    # Nobteook server user: https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile#L33
    NB_USER="root" \
    USER_GID=0 \
    XDG_CACHE_HOME="/root/.cache/" \
    XDG_RUNTIME_DIR="/tmp" \
    DISPLAY=":1" \
    TERM="xterm" \
    DEBIAN_FRONTEND="noninteractive" \
    RESOURCES_PATH="/resources" \
    SSL_RESOURCES_PATH="/resources/ssl" \
    WORKSPACE_HOME="/workspace"

WORKDIR $HOME

# Make folders
RUN \
    mkdir $RESOURCES_PATH && chmod a+rwx $RESOURCES_PATH && \
    mkdir $WORKSPACE_HOME && chmod a+rwx $WORKSPACE_HOME && \
    mkdir $SSL_RESOURCES_PATH && chmod a+rwx $SSL_RESOURCES_PATH

# Layer cleanup script
COPY resources/scripts/clean-layer.sh  /usr/bin/clean-layer.sh
COPY resources/scripts/fix-permissions.sh  /usr/bin/fix-permissions.sh

 # Make clean-layer and fix-permissions executable
 RUN \
    chmod a+rwx /usr/bin/clean-layer.sh && \
    chmod a+rwx /usr/bin/fix-permissions.sh

# Generate and Set locals
# https://stackoverflow.com/questions/28405902/how-to-set-the-locale-inside-a-debian-ubuntu-docker-container#38553499
RUN \
    apt-get update && \
    apt-get install -y locales && \
    # install locales-all?
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 && \
    # Cleanup
    clean-layer.sh

ENV LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en"

# Install basics

USER root
RUN \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get -qq -y install tzdata default-jdk && \
    chmod 777 -R /root && \
    chmod 777 -R /usr && \
    clean-layer.sh
RUN wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz && \
    tar -zxf ta-lib-0.4.0-src.tar.gz && \
    cd ta-lib && \
    ./configure --prefix=/usr && \
    make && \
    make install && \
    clean-layer.sh

USER ${NB_UID}

RUN pip install --upgrade pip wheel setuptools ta-lib pandas matplotlib bokeh plotly pandas_bokeh datatile ratelimiter pytz psutil pympler asyncio loguru sqlalchemy psycopg2-binary questdb toml tqdm pandas_market_calendars yfinance celery redis netifaces ib_insync ibapi tabulate requests slack_sdk ffn pandas_ta ta finta matplotlib numpy statsmodels scikit-learn scipy jupyter-lsp python-language-server[all] jupyter_contrib_nbextensions && \
    clean-layer.sh

RUN bokeh sampledata && \
    clean-layer.sh

RUN pip install --upgrade pyspark && \
    clean-layer.sh

RUN pyspark --packages io.delta:delta-core_2.12:2.2.0 --conf "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension" --conf "spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog" && \
    clean-layer.sh

RUN pip install delta-spark==2.2.0 && \
    clean-layer.sh

RUN pip install --upgrade mlflow[extras] && \
    clean-layer.sh

RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    clean-layer.sh

RUN mkdir -p ~/.jupyterlab/user-settings/@jupyterlab/apputils-extension/ && \
    echo '{ "theme":"JupyterLab Dark" }' > themes.jupyterlab-settings

RUN jupyter labextension install @krassowski/jupyterlab-lsp && \
    clean-layer.sh

RUN jupyter contrib nbextension install && \
    clean-layer.sh

RUN pip install --upgrade neptune-client && \
    clean-layer.sh

RUN pip install --upgrade neptune-notebooks && \
    clean-layer.sh

RUN jupyter nbextension enable --py neptune-notebooks && \
    clean-layer.sh

RUN jupyter lab build && \
    clean-layer.sh

RUN pip install --upgrade jupyterthemes && \
    clean-layer.sh

RUN jt -t monokai -f fira -fs 10 -nf ptsans -nfs 11 -N -kl -cursw 2 -cursc r -cellw 95% -T && \
    clean-layer.sh

RUN pip install jupyterlab-horizon-theme && \
    clean-layer.sh

# RUN pip install perspective-python && \
#     clean-layer.sh

# RUN jupyter labextension install @finos/perspective-jupyterlab && \
#     clean-layer.sh

RUN pip install mitosheet && \
    clean-layer.sh

RUN pip install --upgrade jupyterlab_execute_time && \
    clean-layer.sh

RUN pip install --upgrade jupyterlab_nvdashboard && \
    clean-layer.sh


RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    clean-layer.sh

RUN jupyter labextension install plotlywidget && \
    clean-layer.sh

# RUN jupyter labextension install @jupyterlab/plotly-extension && \
#     clean-layer.sh

# RUN jupyter labextension install jupyterlab_bokeh && \
#     clean-layer.sh

# RUN jupyter labextension install qgrid && \
#     clean-layer.sh

# RUN jupyter labextension install ipysheet && \
#     clean-layer.sh

# RUN jupyter labextension install lineup_widget && \
#     clean-layer.sh

# RUN pip install pylantern && \
#     clean-layer.sh

# Build instructions

# cd Xfer
# cd workstation
# docker build -t chuckmelanson/workstation < Dockerfile .
# cd ..
# docker-compose up -d

# Post install instructions
# From inside the container....
# python -m pip install mitosheet
# python -m jupyter nbextension install --py --user mitosheet
# python -m jupyter nbextension enable --py --user mitosheet


# pip install pylantern

# Save the container
# docker ps
# <get image id>
# docker commit <image id goes here> chuckmelanson/workstation:latest



