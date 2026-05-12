ARCHIVES=archives
COMPRESSED=compressed

.PHONY: fetch index compress extract cleanup serve sanitize

fetch:
	@echo "Fetching documentation..."
	@bash scripts/fetch.sh

compress:
	@echo "Compressing archives..."
	@mkdir -p $(COMPRESSED)
	@for dir in $(ARCHIVES)/*; do \
		name=$$(basename $$dir); \
		echo "Compressing $$name"; \
		tar --use-compress-program=zstd -cf $(COMPRESSED)/$$name.tar.zst -C $(ARCHIVES) $$name; \
	done

extract:
	@echo "Extracting compressed docs..."
	@mkdir -p $(ARCHIVES)
	@for file in $(COMPRESSED)/*.tar.zst; do \
		name=$$(basename $$file .tar.zst); \
		echo "Extracting $$name"; \
		tar --use-compress-program=zstd -xf $$file -C $(ARCHIVES)/; \
	done
	@echo "Creating symlink of $(ARCHIVES) in web..."
	@cd web && ln -s ../$(ARCHIVES) $(ARCHIVES)

index:
	@echo "Building local search index..."
	@python3 scripts/indexer.py

cleanup:
	@echo "Cleaning extracted docs..."
	@rm -rf $(ARCHIVES)/*
	@rm web/$(ARCHIVES)

serve:
	@echo ""
	@echo "sdocs local server"
	@echo "-------------------"
	@echo "URL: http://localhost:8000"
	@echo ""
	cd web && python3 -m http.server 8000

sanitize:
	python scripts/sanitize_assets.py
