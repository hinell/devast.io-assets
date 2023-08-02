SHELL=zsh
URL ?=https://devast.io/

INPUT_URL_LIST ?=assets-img.txt
OUTPUT_DIR=img/

CURL_FLAGS?=-O --create-dirs --output-dir $(OUTPUT_DIR)
# $(info $(IMAGES_LIST))

#-----------------------------------------------------------------------targetrs
.DEFAULT: all
.PHONY:all
.ONESHELL:
all: img/

.PHONY: help
.ONESHELL:
help: 
	@clear
	@cat <<-EOL
	 Usage: make img/ # to download images 
	 	or: make all # makes all
	devast.io assets downloader

	Copyright:
	  Copyright (C) 2023- Alex A. Davronov <al.neodim@gmail.com>
	  See LICENSE file or comment at the top of the main file
	  provided along with the source code for additional info
	  
	  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	  SOFTWARE.
	EOL

# This prints CLIENT_URI e.g. "client.*.min.js"
# You will have to manually insert it into CLIENT_URI var below
# THIS WON'T CREATE ANY FILES"
.PHONY: client-uri
.ONESHELL:
client-uri: 
	@TMPINDEXFILE=/tmp/devast.io.html
	@test -f $${TMPINDEXFILE} || curl -o $${TMPINDEXFILE} -s https://devast.io/
	@grep -o -E "js/client.*.min.js" "$${TMPINDEXFILE}"


.ONESHELL:
js/client.30.1982.min.js:
	@if [[ ! -e $(@) ]];
	then
		curl -o $(@) $(URL)/$(@)
	fi

.ONESHELL:
js/client.min.js: js/client.30.1982.min.js
	@pushd js/
	@test -L $(@) || ln -s $(notdir $(<)) $(notdir $(@))
	@popd
	

# Extracts all images links from client.js into a txt with rows of URIs
# You have to manually edit file to prevent parsing errors though 
.ONESHELL:
$(INPUT_URL_LIST): js/client.min.js
	@echo -e "$$(cat $(<))" |  grep -oE  "img/.*\.png" | sed -E "s/'.*'/\n/" > $@
	@command -v node && {
		node rows-uniq.mjs $(INPUT_URL_LIST) $(INPUT_URL_LIST).tmp
		rm $(INPUT_URL_LIST)
		mv $(INPUT_URL_LIST).tmp $(INPUT_URL_LIST)
	}

# Create dir to output images
.PHONY: img.d
.ONESHELL:
img.d:
	[[ -d "$(OUTPUT_DIR)" ]] || mkdir -v "$(OUTPUT_DIR)"

img/%.png: | img.d
	# @echo $(URL)$@
	sleep 1s && curl $(CURL_FLAGS) "$(URL)$@";

.PHONY: _IMAGES
_IMAGES: 
# 	$(eval IMAGES=$(shell cat $(INPUT_URL_LIST)))

# The list of .png files is automatically generated and loaded 
img/: $(shell cat "$(INPUT_URL_LIST)"; ) | $(INPUT_URL_LIST)
	:

