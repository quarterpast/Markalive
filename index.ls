require! esprima

flatten = (arr)->
	| typeof! arr is \Array => concat-map flatten,arr
	| otherwise => [arr]

traverse = (func,node)-->
	[func node] ++ for own key,child of node
		switch typeof! child
		| \Array  => map (traverse func), child
		| \Object => traverse func, child

get-tag-calls = (f)->
	esprima.parse "(#{f.to-string!})"
	|> traverse (node)->
		if and-list zip-with (is), [
			node.type
			node.callee?.type
			node.callee?.object?.type
		],<[ CallExpression MemberExpression ThisExpression ]> then node.callee.property.name
	|> flatten
	|> filter (?)

html-escape = (x)->
	x ? ""
	.to-string!
	.replace /&/g, "&amp;"
	.replace />/g,"&gt;"
	.replace /</g, "&lt;"
	.replace /\"/g, '&quot;'

String::render = String::to-string

class Tag
	@create = (name)->->Tag name,...&
	(@name,@attrs = {},...@kids)~>
		if attrs? and typeof! attrs isnt \Object or attrs instanceof Tag
			@kids.unshift attrs
			@attrs = {}

	format-attr-val = (name,val)->switch typeof! val
		| \Function  => format-attr-val val!
		| \Array     => unwords val
		| \Object    => JSON.stringify val
		| \Undefined => ""
		| \Boolean   => (if val then name else "")
		| otherwise  => val.to-string!

	write-attrs: ->
		unwords [""] ++ ["#{attr}=\"#{html-escape format-attr-val attr,val}\"" for attr,val of @attrs when attr == /^[a-z_:][-a-z0-9_:.]*$/i]

	render: (indent = '')->
		join '\n' [
			"#indent<#{@name}#{@write-attrs!}>"
			...[node.render indent+'  ' for node in @kids]
			"#indent</#{@name}>"
		]

module.exports = markalive = (fn)->
	ctx = {[n,Tag.create n] for n in get-tag-calls fn}
	render: ->fn.call ctx,it .render!