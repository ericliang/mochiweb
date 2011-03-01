REL_DIR:=./rel
REBAR=./rebar
APPID={{appid}}
NODEID=$(APPID)_node

all:
	@$(REBAR) get-deps compile

edoc:
	@$(REBAR) doc

test:
	@rm -rf .eunit
	@mkdir -p .eunit
	@$(REBAR) skip_deps=true eunit

clean:
	@$(REBAR) clean

build_plt:
	@$(REBAR) build-plt

dialyzer:
	@$(REBAR) dialyze

release:
	@mkdir -p $(REL_DIR)
	@cd $(REL_DIR) && ../$(REBAR) create-node nodeid=$(NODEID)
	@echo "==> You should edit the file: ./rel/reltool.config, and then run: ./rebar generate"