FROM ubuntu:18.04 
WORKDIR /root
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true
RUN apt-get update && apt-get install -y ca-certificates && update-ca-certificates && apt-get install -y openssl
RUN apt-get install -y software-properties-common 
RUN add-apt-repository universe && add-apt-repository ppa:openscad/releases && apt-get update
RUN apt-get install -y openscad
RUN apt-get install -y ruby-full
# Slic3r
RUN apt-get install -y wget
RUN apt-get install -y libgtk2.0
RUN wget https://github.com/prusa3d/Slic3r/releases/download/version_1.41.1/Slic3rPE-1.41.1+linux64-full-201810261150.AppImage -O slic3r.AppImage
RUN chmod +x ./slic3r.AppImage
RUN ./slic3r.AppImage  --appimage-extract && rm -f slic3r && ln -s `pwd`/squashfs-root/AppRun slic3r
# For make
RUN apt-get install -y build-essential
RUN echo 'gem: --no-document' > /etc/gemrc
RUN gem install bundler
ADD ./ .
RUN make
ENV OPENSCAD_EXEC  "openscad"
ENV SLIC3R_EXEC "./slic3r --no-gui" 
ENTRYPOINT ["ruby", "gen_temp_tower.rb"]
