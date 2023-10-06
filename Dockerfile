################################################################################
# Dockerfile that builds 'yanwk/comfyui-boot:latest'
# A runtime environment for https://github.com/comfyanonymous/ComfyUI
################################################################################

FROM ubuntu:latest

LABEL maintainer="code@yanwk.fun"

RUN apt-get update && apt-get install -y \
        python3 python3-pip \
        python3-wheel python3-setuptools python3-numpy \
        shadow git aria2 \
        libgl1-mesa-glx

# Install PyTorch (stable version)
RUN pip3 install --no-cache-dir \
        torch torchvision

# Install xFormers (stable version)
RUN pip3 install --no-cache-dir \
        xformers

# Deps for main app
RUN pip3 install --no-cache-dir \
        -r https://raw.githubusercontent.com/comfyanonymous/ComfyUI/master/requirements.txt

# Deps for ControlNet Auxiliary Preprocessors
RUN pip3 install --no-cache-dir \
        -r https://raw.githubusercontent.com/Fannovel16/comfyui_controlnet_aux/main/requirements.txt

# Fix for CuDNN
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/lib/python3.9/site-packages/torch/lib"

# Create a low-privilege user.
RUN printf 'CREATE_MAIL_SPOOL=no' > /etc/default/useradd \
    && mkdir -p /home/runner /home/scripts \
    && groupadd runner \
    && useradd runner -g runner -d /home/runner \
    && chown runner:runner /home/runner /home/scripts

COPY --chown=runner:runner scripts/. /home/scripts/

USER runner:runner
VOLUME /home/runner
WORKDIR /home/runner
EXPOSE 8188
ENV CLI_ARGS=""
CMD ["bash","/home/scripts/entrypoint.sh"]