################################################################################
# Dockerfile that builds 'yanwk/comfyui-boot:latest'
# A runtime environment for https://github.com/comfyanonymous/ComfyUI
################################################################################

FROM ubuntu:latest

LABEL maintainer="code@yanwk.fun"

RUN --mount=type=cache,target=/var/cache/apt apt update
RUN --mount=type=cache,target=/var/cache/apt apt install -y python3
RUN --mount=type=cache,target=/var/cache/apt apt update
RUN --mount=type=cache,target=/var/cache/apt apt install -y python3-pip
RUN --mount=type=cache,target=/var/cache/apt apt update
RUN --mount=type=cache,target=/var/cache/apt apt install -y python3-wheel
RUN --mount=type=cache,target=/var/cache/apt apt update
RUN --mount=type=cache,target=/var/cache/apt apt install -y python3-setuptools
RUN --mount=type=cache,target=/var/cache/apt apt update
RUN --mount=type=cache,target=/var/cache/apt apt install -y python3-numpy
RUN --mount=type=cache,target=/var/cache/apt apt update
RUN --mount=type=cache,target=/var/cache/apt apt install -y shadow
RUN --mount=type=cache,target=/var/cache/apt apt update
RUN --mount=type=cache,target=/var/cache/apt apt install -y git
RUN --mount=type=cache,target=/var/cache/apt apt update
RUN --mount=type=cache,target=/var/cache/apt apt install -y aria2
RUN --mount=type=cache,target=/var/cache/apt apt update
RUN --mount=type=cache,target=/var/cache/apt apt install -y libgl1-mesa-glx
RUN --mount=type=cache,target=/var/cache/apt apt update

# Install PyTorch (stable version)
RUN --mount=type=cache,target=/root/.cache/pip pip3 install --no-cache-dir torch torchvision

# Install xFormers (stable version)
RUN --mount=type=cache,target=/root/.cache/pip pip3 install --no-cache-dir xformers

# Deps for main app
RUN --mount=type=cache,target=/root/.cache/pip pip3 install --no-cache-dir -r https://raw.githubusercontent.com/comfyanonymous/ComfyUI/master/requirements.txt

# Deps for ControlNet Auxiliary Preprocessors
RUN --mount=type=cache,target=/root/.cache/pip pip3 install --no-cache-dir -r https://raw.githubusercontent.com/Fannovel16/comfyui_controlnet_aux/main/requirements.txt

# Fix for CuDNN
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/lib/python3.9/site-packages/torch/lib"

# Create a low-privilege user.
RUN printf 'CREATE_MAIL_SPOOL=no' > /etc/default/useradd && mkdir -p /home/runner /home/scripts && groupadd runner && useradd runner -g runner -d /home/runner && chown runner:runner /home/runner /home/scripts

COPY --chown=runner:runner scripts/. /home/scripts/

USER runner:runner
VOLUME /home/runner
WORKDIR /home/runner
EXPOSE 8188
ENV CLI_ARGS=""
CMD ["bash","/home/scripts/entrypoint.sh"]