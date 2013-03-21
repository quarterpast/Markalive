markalive = require "./index"

m = markalive ->
	@html lang:\en,
		@head do
			@meta charset:\utf8
			@title "Test"
		@body do
			@ul "hi"

console.log m.render!