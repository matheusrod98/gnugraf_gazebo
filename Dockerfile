# ROS2 distro
FROM ros:foxy-ros-base

# Default shell for installtion process and image.
SHELL ["/bin/bash", "-c"]

RUN apt update && apt upgrade -y
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y --install-recommends tmux imagemagick git cmake make

RUN mkdir -p /root/Presentation/dolly/src \
    && source /opt/ros/foxy/setup.bash \
    && cd /root/Presentation/dolly/src \
    && git clone https://github.com/chapulina/dolly.git -b foxy \
    && cd .. \
    && rosdep install --from-paths src --ignore-src -r -y \
    && colcon build

# Install simslides from main branch.
RUN mkdir -p /root/Presentation/
RUN export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH \
    && cd /root/Presentation \
    && git clone https://github.com/chapulina/simslides.git \
    && cd /root/Presentation/simslides \
    && mkdir build \
    && cd build \
    && source /opt/ros/foxy/setup.bash \
    && cmake .. \
    && make \
    && make install \
    && cd ..

# tmux niceties.
RUN echo "set -g mouse on" >> /root/.tmux.conf
RUN echo "set-option -g history-limit 20000" >> /root/.tmux.conf

# This is necessary to Gazebo be able to find the simslides shared libraries.
RUN echo "source /opt/ros/foxy/setup.bash" >> /root/.bashrc
RUN echo "source /usr/share/gazebo/setup.sh" >> /root/.bashrc
RUN echo "export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH" >> /root/.profile

# Default startup directory
WORKDIR /root/Presentation
