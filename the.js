(function(scope){
'use strict';

function F(arity, fun, wrapper) {
  wrapper.a = arity;
  wrapper.f = fun;
  return wrapper;
}

function F2(fun) {
  return F(2, fun, function(a) { return function(b) { return fun(a,b); }; })
}
function F3(fun) {
  return F(3, fun, function(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  });
}
function F4(fun) {
  return F(4, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  });
}
function F5(fun) {
  return F(5, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  });
}
function F6(fun) {
  return F(6, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  });
}
function F7(fun) {
  return F(7, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  });
}
function F8(fun) {
  return F(8, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  });
}
function F9(fun) {
  return F(9, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  });
}

function A2(fun, a, b) {
  return fun.a === 2 ? fun.f(a, b) : fun(a)(b);
}
function A3(fun, a, b, c) {
  return fun.a === 3 ? fun.f(a, b, c) : fun(a)(b)(c);
}
function A4(fun, a, b, c, d) {
  return fun.a === 4 ? fun.f(a, b, c, d) : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e) {
  return fun.a === 5 ? fun.f(a, b, c, d, e) : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f) {
  return fun.a === 6 ? fun.f(a, b, c, d, e, f) : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g) {
  return fun.a === 7 ? fun.f(a, b, c, d, e, f, g) : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h) {
  return fun.a === 8 ? fun.f(a, b, c, d, e, f, g, h) : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i) {
  return fun.a === 9 ? fun.f(a, b, c, d, e, f, g, h, i) : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}




var _JsArray_empty = [];

function _JsArray_singleton(value)
{
    return [value];
}

function _JsArray_length(array)
{
    return array.length;
}

var _JsArray_initialize = F3(function(size, offset, func)
{
    var result = new Array(size);

    for (var i = 0; i < size; i++)
    {
        result[i] = func(offset + i);
    }

    return result;
});

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = new Array(max);

    for (var i = 0; i < max && ls.b; i++)
    {
        result[i] = ls.a;
        ls = ls.b;
    }

    result.length = i;
    return _Utils_Tuple2(result, ls);
});

var _JsArray_unsafeGet = F2(function(index, array)
{
    return array[index];
});

var _JsArray_unsafeSet = F3(function(index, value, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[index] = value;
    return result;
});

var _JsArray_push = F2(function(value, array)
{
    var length = array.length;
    var result = new Array(length + 1);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[length] = value;
    return result;
});

var _JsArray_foldl = F3(function(func, acc, array)
{
    var length = array.length;

    for (var i = 0; i < length; i++)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(func, acc, array)
{
    for (var i = array.length - 1; i >= 0; i--)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(func, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = func(array[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(func, offset, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = A2(func, offset + i, array[i]);
    }

    return result;
});

var _JsArray_slice = F3(function(from, to, array)
{
    return array.slice(from, to);
});

var _JsArray_appendN = F3(function(n, dest, source)
{
    var destLen = dest.length;
    var itemsToCopy = n - destLen;

    if (itemsToCopy > source.length)
    {
        itemsToCopy = source.length;
    }

    var size = destLen + itemsToCopy;
    var result = new Array(size);

    for (var i = 0; i < destLen; i++)
    {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++)
    {
        result[i + destLen] = source[i];
    }

    return result;
});



var _List_Nil = { $: 0 };
var _List_Nil_UNUSED = { $: '[]' };

function _List_Cons(hd, tl) { return { $: 1, a: hd, b: tl }; }
function _List_Cons_UNUSED(hd, tl) { return { $: '::', a: hd, b: tl }; }


var _List_cons = F2(_List_Cons);

function _List_fromArray(arr)
{
	var out = _List_Nil;
	for (var i = arr.length; i--; )
	{
		out = _List_Cons(arr[i], out);
	}
	return out;
}

function _List_toArray(xs)
{
	for (var out = []; xs.b; xs = xs.b) // WHILE_CONS
	{
		out.push(xs.a);
	}
	return out;
}

var _List_map2 = F3(function(f, xs, ys)
{
	for (var arr = []; xs.b && ys.b; xs = xs.b, ys = ys.b) // WHILE_CONSES
	{
		arr.push(A2(f, xs.a, ys.a));
	}
	return _List_fromArray(arr);
});

var _List_map3 = F4(function(f, xs, ys, zs)
{
	for (var arr = []; xs.b && ys.b && zs.b; xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A3(f, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map4 = F5(function(f, ws, xs, ys, zs)
{
	for (var arr = []; ws.b && xs.b && ys.b && zs.b; ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A4(f, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map5 = F6(function(f, vs, ws, xs, ys, zs)
{
	for (var arr = []; vs.b && ws.b && xs.b && ys.b && zs.b; vs = vs.b, ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A5(f, vs.a, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_sortBy = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		return _Utils_cmp(f(a), f(b));
	}));
});

var _List_sortWith = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		var ord = A2(f, a, b);
		return ord === elm$core$Basics$EQ ? 0 : ord === elm$core$Basics$LT ? -1 : 1;
	}));
});



// LOG

var _Debug_log = F2(function(tag, value)
{
	return value;
});

var _Debug_log_UNUSED = F2(function(tag, value)
{
	console.log(tag + ': ' + _Debug_toString(value));
	return value;
});


// TODOS

function _Debug_todo(moduleName, region)
{
	return function(message) {
		_Debug_crash(8, moduleName, region, message);
	};
}

function _Debug_todoCase(moduleName, region, value)
{
	return function(message) {
		_Debug_crash(9, moduleName, region, value, message);
	};
}


// TO STRING

function _Debug_toString(value)
{
	return '<internals>';
}

function _Debug_toString_UNUSED(value)
{
	return _Debug_toAnsiString(false, value);
}

function _Debug_toAnsiString(ansi, value)
{
	if (typeof value === 'function')
	{
		return _Debug_internalColor(ansi, '<function>');
	}

	if (typeof value === 'boolean')
	{
		return _Debug_ctorColor(ansi, value ? 'True' : 'False');
	}

	if (typeof value === 'number')
	{
		return _Debug_numberColor(ansi, value + '');
	}

	if (value instanceof String)
	{
		return _Debug_charColor(ansi, "'" + _Debug_addSlashes(value, true) + "'");
	}

	if (typeof value === 'string')
	{
		return _Debug_stringColor(ansi, '"' + _Debug_addSlashes(value, false) + '"');
	}

	if (typeof value === 'object' && '$' in value)
	{
		var tag = value.$;

		if (typeof tag === 'number')
		{
			return _Debug_internalColor(ansi, '<internals>');
		}

		if (tag[0] === '#')
		{
			var output = [];
			for (var k in value)
			{
				if (k === '$') continue;
				output.push(_Debug_toAnsiString(ansi, value[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (tag === 'Set_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Set')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, elm$core$Set$toList(value));
		}

		if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Dict')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, elm$core$Dict$toList(value));
		}

		if (tag === 'Array_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Array')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, elm$core$Array$toList(value));
		}

		if (tag === '::' || tag === '[]')
		{
			var output = '[';

			value.b && (output += _Debug_toAnsiString(ansi, value.a), value = value.b)

			for (; value.b; value = value.b) // WHILE_CONS
			{
				output += ',' + _Debug_toAnsiString(ansi, value.a);
			}
			return output + ']';
		}

		var output = '';
		for (var i in value)
		{
			if (i === '$') continue;
			var str = _Debug_toAnsiString(ansi, value[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '[' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return _Debug_ctorColor(ansi, tag) + output;
	}

	if (typeof value === 'object')
	{
		var output = [];
		for (var key in value)
		{
			var field = key[0] === '_' ? key.slice(1) : key;
			output.push(_Debug_fadeColor(ansi, field) + ' = ' + _Debug_toAnsiString(ansi, value[key]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return _Debug_internalColor(ansi, '<internals>');
}

function _Debug_addSlashes(str, isChar)
{
	var s = str
		.replace(/\\/g, '\\\\')
		.replace(/\n/g, '\\n')
		.replace(/\t/g, '\\t')
		.replace(/\r/g, '\\r')
		.replace(/\v/g, '\\v')
		.replace(/\0/g, '\\0');

	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}

function _Debug_ctorColor(ansi, string)
{
	return ansi ? '\x1b[96m' + string + '\x1b[0m' : string;
}

function _Debug_numberColor(ansi, string)
{
	return ansi ? '\x1b[95m' + string + '\x1b[0m' : string;
}

function _Debug_stringColor(ansi, string)
{
	return ansi ? '\x1b[93m' + string + '\x1b[0m' : string;
}

function _Debug_charColor(ansi, string)
{
	return ansi ? '\x1b[92m' + string + '\x1b[0m' : string;
}

function _Debug_fadeColor(ansi, string)
{
	return ansi ? '\x1b[37m' + string + '\x1b[0m' : string;
}

function _Debug_internalColor(ansi, string)
{
	return ansi ? '\x1b[94m' + string + '\x1b[0m' : string;
}



// CRASH


function _Debug_crash(identifier)
{
	throw new Error('https://github.com/elm/core/blob/1.0.0/hints/' + identifier + '.md');
}


function _Debug_crash_UNUSED(identifier, fact1, fact2, fact3, fact4)
{
	switch(identifier)
	{
		case 0:
			throw new Error('What node should I take over? In JavaScript I need something like:\n\n    Elm.Main.init({\n        node: document.getElementById("elm-node")\n    })\n\nYou need to do this with any Browser.sandbox or Browser.element program.');

		case 1:
			throw new Error('Browser.application programs cannot handle URLs like this:\n\n    ' + document.location.href + '\n\nWhat is the root? The root of your file system? Try looking at this program with `elm reactor` or some other server.');

		case 2:
			var jsonErrorString = fact1;
			throw new Error('Problem with the flags given to your Elm program on initialization.\n\n' + jsonErrorString);

		case 3:
			var portName = fact1;
			throw new Error('There can only be one port named `' + portName + '`, but your program has multiple.');

		case 4:
			var portName = fact1;
			var problem = fact2;
			throw new Error('Trying to send an unexpected type of value through port `' + portName + '`:\n' + problem);

		case 5:
			throw new Error('Trying to use `(==)` on functions.\nThere is no way to know if functions are "the same" in the Elm sense.\nRead more about this at https://package.elm-lang.org/packages/elm/core/latest/Basics#== which describes why it is this way and what the better version will look like.');

		case 6:
			var moduleName = fact1;
			throw new Error('Your page is loading multiple Elm scripts with a module named ' + moduleName + '. Maybe a duplicate script is getting loaded accidentally? If not, rename one of them so I know which is which!');

		case 8:
			var moduleName = fact1;
			var region = fact2;
			var message = fact3;
			throw new Error('TODO in module `' + moduleName + '` ' + _Debug_regionToString(region) + '\n\n' + message);

		case 9:
			var moduleName = fact1;
			var region = fact2;
			var value = fact3;
			var message = fact4;
			throw new Error(
				'TODO in module `' + moduleName + '` from the `case` expression '
				+ _Debug_regionToString(region) + '\n\nIt received the following value:\n\n    '
				+ _Debug_toString(value).replace('\n', '\n    ')
				+ '\n\nBut the branch that handles it says:\n\n    ' + message.replace('\n', '\n    ')
			);

		case 10:
			throw new Error('Bug in https://github.com/elm/virtual-dom/issues');

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');
	}
}

function _Debug_regionToString(region)
{
	if (region.ab.K === region.ai.K)
	{
		return 'on line ' + region.ab.K;
	}
	return 'on lines ' + region.ab.K + ' through ' + region.ai.K;
}



// EQUALITY

function _Utils_eq(x, y)
{
	for (
		var pair, stack = [], isEqual = _Utils_eqHelp(x, y, 0, stack);
		isEqual && (pair = stack.pop());
		isEqual = _Utils_eqHelp(pair.a, pair.b, 0, stack)
		)
	{}

	return isEqual;
}

function _Utils_eqHelp(x, y, depth, stack)
{
	if (depth > 100)
	{
		stack.push(_Utils_Tuple2(x,y));
		return true;
	}

	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object' || x === null || y === null)
	{
		typeof x === 'function' && _Debug_crash(5);
		return false;
	}

	/**_UNUSED/
	if (x.$ === 'Set_elm_builtin')
	{
		x = elm$core$Set$toList(x);
		y = elm$core$Set$toList(y);
	}
	if (x.$ === 'RBNode_elm_builtin' || x.$ === 'RBEmpty_elm_builtin')
	{
		x = elm$core$Dict$toList(x);
		y = elm$core$Dict$toList(y);
	}
	//*/

	/**/
	if (x.$ < 0)
	{
		x = elm$core$Dict$toList(x);
		y = elm$core$Dict$toList(y);
	}
	//*/

	for (var key in x)
	{
		if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

var _Utils_equal = F2(_Utils_eq);
var _Utils_notEqual = F2(function(a, b) { return !_Utils_eq(a,b); });



// COMPARISONS

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

function _Utils_cmp(x, y, ord)
{
	if (typeof x !== 'object')
	{
		return x === y ? /*EQ*/ 0 : x < y ? /*LT*/ -1 : /*GT*/ 1;
	}

	/**_UNUSED/
	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? 0 : a < b ? -1 : 1;
	}
	//*/

	/**/
	if (!x.$)
	//*/
	/**_UNUSED/
	if (x.$[0] === '#')
	//*/
	{
		return (ord = _Utils_cmp(x.a, y.a))
			? ord
			: (ord = _Utils_cmp(x.b, y.b))
				? ord
				: _Utils_cmp(x.c, y.c);
	}

	// traverse conses until end of a list or a mismatch
	for (; x.b && y.b && !(ord = _Utils_cmp(x.a, y.a)); x = x.b, y = y.b) {} // WHILE_CONSES
	return ord || (x.b ? /*GT*/ 1 : y.b ? /*LT*/ -1 : /*EQ*/ 0);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) < 0; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) < 1; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) > 0; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) >= 0; });

var _Utils_compare = F2(function(x, y)
{
	var n = _Utils_cmp(x, y);
	return n < 0 ? elm$core$Basics$LT : n ? elm$core$Basics$GT : elm$core$Basics$EQ;
});


// COMMON VALUES

var _Utils_Tuple0 = 0;
var _Utils_Tuple0_UNUSED = { $: '#0' };

function _Utils_Tuple2(a, b) { return { a: a, b: b }; }
function _Utils_Tuple2_UNUSED(a, b) { return { $: '#2', a: a, b: b }; }

function _Utils_Tuple3(a, b, c) { return { a: a, b: b, c: c }; }
function _Utils_Tuple3_UNUSED(a, b, c) { return { $: '#3', a: a, b: b, c: c }; }

function _Utils_chr(c) { return c; }
function _Utils_chr_UNUSED(c) { return new String(c); }


// RECORDS

function _Utils_update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


// APPEND

var _Utils_append = F2(_Utils_ap);

function _Utils_ap(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (!xs.b)
	{
		return ys;
	}
	var root = _List_Cons(xs.a, ys);
	xs = xs.b
	for (var curr = root; xs.b; xs = xs.b) // WHILE_CONS
	{
		curr = curr.b = _List_Cons(xs.a, ys);
	}
	return root;
}



// TASKS

function _Scheduler_succeed(value)
{
	return {
		$: 0,
		a: value
	};
}

function _Scheduler_fail(error)
{
	return {
		$: 1,
		a: error
	};
}

function _Scheduler_binding(callback)
{
	return {
		$: 2,
		b: callback,
		c: null
	};
}

var _Scheduler_andThen = F2(function(callback, task)
{
	return {
		$: 3,
		b: callback,
		d: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		$: 4,
		b: callback,
		d: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		$: 5,
		b: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var proc = {
		$: 0,
		e: _Scheduler_guid++,
		f: task,
		g: null,
		h: []
	};

	_Scheduler_enqueue(proc);

	return proc;
}

function _Scheduler_spawn(task)
{
	return _Scheduler_binding(function(callback) {
		callback(_Scheduler_succeed(_Scheduler_rawSpawn(task)));
	});
}

function _Scheduler_rawSend(proc, msg)
{
	proc.h.push(msg);
	_Scheduler_enqueue(proc);
}

var _Scheduler_send = F2(function(proc, msg)
{
	return _Scheduler_binding(function(callback) {
		_Scheduler_rawSend(proc, msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});

function _Scheduler_kill(proc)
{
	return _Scheduler_binding(function(callback) {
		var task = proc.f;
		if (task.$ === 2 && task.c)
		{
			task.c();
		}

		proc.f = null;

		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
}


/* STEP PROCESSES

type alias Process =
  { $ : tag
  , id : unique_id
  , root : Task
  , stack : null | { $: SUCCEED | FAIL, a: callback, b: stack }
  , mailbox : [msg]
  }

*/


var _Scheduler_working = false;
var _Scheduler_queue = [];


function _Scheduler_enqueue(proc)
{
	_Scheduler_queue.push(proc);
	if (_Scheduler_working)
	{
		return;
	}
	_Scheduler_working = true;
	while (proc = _Scheduler_queue.shift())
	{
		_Scheduler_step(proc);
	}
	_Scheduler_working = false;
}


function _Scheduler_step(proc)
{
	while (proc.f)
	{
		var rootTag = proc.f.$;
		if (rootTag === 0 || rootTag === 1)
		{
			while (proc.g && proc.g.$ !== rootTag)
			{
				proc.g = proc.g.i;
			}
			if (!proc.g)
			{
				return;
			}
			proc.f = proc.g.b(proc.f.a);
			proc.g = proc.g.i;
		}
		else if (rootTag === 2)
		{
			proc.f.c = proc.f.b(function(newRoot) {
				proc.f = newRoot;
				_Scheduler_enqueue(proc);
			});
			return;
		}
		else if (rootTag === 5)
		{
			if (proc.h.length === 0)
			{
				return;
			}
			proc.f = proc.f.b(proc.h.shift());
		}
		else // if (rootTag === 3 || rootTag === 4)
		{
			proc.g = {
				$: rootTag === 3 ? 0 : 1,
				b: proc.f.b,
				i: proc.g
			};
			proc.f = proc.f.d;
		}
	}
}



// MATH

var _Basics_add = F2(function(a, b) { return a + b; });
var _Basics_sub = F2(function(a, b) { return a - b; });
var _Basics_mul = F2(function(a, b) { return a * b; });
var _Basics_fdiv = F2(function(a, b) { return a / b; });
var _Basics_idiv = F2(function(a, b) { return (a / b) | 0; });
var _Basics_pow = F2(Math.pow);

var _Basics_remainderBy = F2(function(b, a) { return a % b; });

// https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf
var _Basics_modBy = F2(function(modulus, x)
{
	var answer = x % modulus;
	return modulus === 0
		? _Debug_crash(11)
		:
	((answer > 0 && modulus < 0) || (answer < 0 && modulus > 0))
		? answer + modulus
		: answer;
});


// TRIGONOMETRY

var _Basics_pi = Math.PI;
var _Basics_e = Math.E;
var _Basics_cos = Math.cos;
var _Basics_sin = Math.sin;
var _Basics_tan = Math.tan;
var _Basics_acos = Math.acos;
var _Basics_asin = Math.asin;
var _Basics_atan = Math.atan;
var _Basics_atan2 = F2(Math.atan2);


// MORE MATH

function _Basics_toFloat(x) { return x; }
function _Basics_truncate(n) { return n | 0; }
function _Basics_isInfinite(n) { return n === Infinity || n === -Infinity; }

var _Basics_ceiling = Math.ceil;
var _Basics_floor = Math.floor;
var _Basics_round = Math.round;
var _Basics_sqrt = Math.sqrt;
var _Basics_log = Math.log;
var _Basics_isNaN = isNaN;


// BOOLEANS

function _Basics_not(bool) { return !bool; }
var _Basics_and = F2(function(a, b) { return a && b; });
var _Basics_or  = F2(function(a, b) { return a || b; });
var _Basics_xor = F2(function(a, b) { return a !== b; });



function _Char_toCode(char)
{
	var code = char.charCodeAt(0);
	if (0xD800 <= code && code <= 0xDBFF)
	{
		return (code - 0xD800) * 0x400 + char.charCodeAt(1) - 0xDC00 + 0x10000
	}
	return code;
}

function _Char_fromCode(code)
{
	return _Utils_chr(
		(code < 0 || 0x10FFFF < code)
			? '\uFFFD'
			:
		(code <= 0xFFFF)
			? String.fromCharCode(code)
			:
		(code -= 0x10000,
			String.fromCharCode(Math.floor(code / 0x400) + 0xD800)
			+
			String.fromCharCode(code % 0x400 + 0xDC00)
		)
	);
}

function _Char_toUpper(char)
{
	return _Utils_chr(char.toUpperCase());
}

function _Char_toLower(char)
{
	return _Utils_chr(char.toLowerCase());
}

function _Char_toLocaleUpper(char)
{
	return _Utils_chr(char.toLocaleUpperCase());
}

function _Char_toLocaleLower(char)
{
	return _Utils_chr(char.toLocaleLowerCase());
}



var _String_cons = F2(function(chr, str)
{
	return chr + str;
});

function _String_uncons(string)
{
	var word = string.charCodeAt(0);
	return word
		? elm$core$Maybe$Just(
			0xD800 <= word && word <= 0xDBFF
				? _Utils_Tuple2(_Utils_chr(string[0] + string[1]), string.slice(2))
				: _Utils_Tuple2(_Utils_chr(string[0]), string.slice(1))
		)
		: elm$core$Maybe$Nothing;
}

var _String_append = F2(function(a, b)
{
	return a + b;
});

function _String_length(str)
{
	return str.length;
}

var _String_map = F2(function(func, string)
{
	var len = string.length;
	var array = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = string.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			array[i] = func(_Utils_chr(string[i] + string[i+1]));
			i += 2;
			continue;
		}
		array[i] = func(_Utils_chr(string[i]));
		i++;
	}
	return array.join('');
});

var _String_filter = F2(function(isGood, str)
{
	var arr = [];
	var len = str.length;
	var i = 0;
	while (i < len)
	{
		var char = str[i];
		var word = str.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += str[i];
			i++;
		}

		if (isGood(_Utils_chr(char)))
		{
			arr.push(char);
		}
	}
	return arr.join('');
});

function _String_reverse(str)
{
	var len = str.length;
	var arr = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = str.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			arr[len - i] = str[i + 1];
			i++;
			arr[len - i] = str[i - 1];
			i++;
		}
		else
		{
			arr[len - i] = str[i];
			i++;
		}
	}
	return arr.join('');
}

var _String_foldl = F3(function(func, state, string)
{
	var len = string.length;
	var i = 0;
	while (i < len)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += string[i];
			i++;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_foldr = F3(function(func, state, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_split = F2(function(sep, str)
{
	return str.split(sep);
});

var _String_join = F2(function(sep, strs)
{
	return strs.join(sep);
});

var _String_slice = F3(function(start, end, str) {
	return str.slice(start, end);
});

function _String_trim(str)
{
	return str.trim();
}

function _String_trimLeft(str)
{
	return str.replace(/^\s+/, '');
}

function _String_trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function _String_words(str)
{
	return _List_fromArray(str.trim().split(/\s+/g));
}

function _String_lines(str)
{
	return _List_fromArray(str.split(/\r\n|\r|\n/g));
}

function _String_toUpper(str)
{
	return str.toUpperCase();
}

function _String_toLower(str)
{
	return str.toLowerCase();
}

var _String_any = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (isGood(_Utils_chr(char)))
		{
			return true;
		}
	}
	return false;
});

var _String_all = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (!isGood(_Utils_chr(char)))
		{
			return false;
		}
	}
	return true;
});

var _String_contains = F2(function(sub, str)
{
	return str.indexOf(sub) > -1;
});

var _String_startsWith = F2(function(sub, str)
{
	return str.indexOf(sub) === 0;
});

var _String_endsWith = F2(function(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
});

var _String_indexes = F2(function(sub, str)
{
	var subLen = sub.length;

	if (subLen < 1)
	{
		return _List_Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}

	return _List_fromArray(is);
});


// TO STRING

function _String_fromNumber(number)
{
	return number + '';
}


// INT CONVERSIONS

function _String_toInt(str)
{
	var total = 0;
	var code0 = str.charCodeAt(0);
	var start = code0 == 0x2B /* + */ || code0 == 0x2D /* - */ ? 1 : 0;

	for (var i = start; i < str.length; ++i)
	{
		var code = str.charCodeAt(i);
		if (code < 0x30 || 0x39 < code)
		{
			return elm$core$Maybe$Nothing;
		}
		total = 10 * total + code - 0x30;
	}

	return i == start
		? elm$core$Maybe$Nothing
		: elm$core$Maybe$Just(code0 == 0x2D ? -total : total);
}


// FLOAT CONVERSIONS

function _String_toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return elm$core$Maybe$Nothing;
	}
	var n = +s;
	// faster isNaN check
	return n === n ? elm$core$Maybe$Just(n) : elm$core$Maybe$Nothing;
}

function _String_fromList(chars)
{
	return _List_toArray(chars).join('');
}




/**_UNUSED/
function _Json_errorToString(error)
{
	return elm$json$Json$Decode$errorToString(error);
}
//*/


// CORE DECODERS

function _Json_succeed(msg)
{
	return {
		$: 0,
		a: msg
	};
}

function _Json_fail(msg)
{
	return {
		$: 1,
		a: msg
	};
}

var _Json_decodeInt = { $: 2 };
var _Json_decodeBool = { $: 3 };
var _Json_decodeFloat = { $: 4 };
var _Json_decodeValue = { $: 5 };
var _Json_decodeString = { $: 6 };

function _Json_decodeList(decoder) { return { $: 7, b: decoder }; }
function _Json_decodeArray(decoder) { return { $: 8, b: decoder }; }

function _Json_decodeNull(value) { return { $: 9, c: value }; }

var _Json_decodeField = F2(function(field, decoder)
{
	return {
		$: 10,
		d: field,
		b: decoder
	};
});

var _Json_decodeIndex = F2(function(index, decoder)
{
	return {
		$: 11,
		e: index,
		b: decoder
	};
});

function _Json_decodeKeyValuePairs(decoder)
{
	return {
		$: 12,
		b: decoder
	};
}

function _Json_mapMany(f, decoders)
{
	return {
		$: 13,
		f: f,
		g: decoders
	};
}

var _Json_andThen = F2(function(callback, decoder)
{
	return {
		$: 14,
		b: decoder,
		h: callback
	};
});

function _Json_oneOf(decoders)
{
	return {
		$: 15,
		g: decoders
	};
}


// DECODING OBJECTS

var _Json_map1 = F2(function(f, d1)
{
	return _Json_mapMany(f, [d1]);
});

var _Json_map2 = F3(function(f, d1, d2)
{
	return _Json_mapMany(f, [d1, d2]);
});

var _Json_map3 = F4(function(f, d1, d2, d3)
{
	return _Json_mapMany(f, [d1, d2, d3]);
});

var _Json_map4 = F5(function(f, d1, d2, d3, d4)
{
	return _Json_mapMany(f, [d1, d2, d3, d4]);
});

var _Json_map5 = F6(function(f, d1, d2, d3, d4, d5)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5]);
});

var _Json_map6 = F7(function(f, d1, d2, d3, d4, d5, d6)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6]);
});

var _Json_map7 = F8(function(f, d1, d2, d3, d4, d5, d6, d7)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
});

var _Json_map8 = F9(function(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
});


// DECODE

var _Json_runOnString = F2(function(decoder, string)
{
	try
	{
		var value = JSON.parse(string);
		return _Json_runHelp(decoder, value);
	}
	catch (e)
	{
		return elm$core$Result$Err(A2(elm$json$Json$Decode$Failure, 'This is not valid JSON! ' + e.message, _Json_wrap(string)));
	}
});

var _Json_run = F2(function(decoder, value)
{
	return _Json_runHelp(decoder, _Json_unwrap(value));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.$)
	{
		case 3:
			return (typeof value === 'boolean')
				? elm$core$Result$Ok(value)
				: _Json_expecting('a BOOL', value);

		case 2:
			if (typeof value !== 'number') {
				return _Json_expecting('an INT', value);
			}

			if (-2147483647 < value && value < 2147483647 && (value | 0) === value) {
				return elm$core$Result$Ok(value);
			}

			if (isFinite(value) && !(value % 1)) {
				return elm$core$Result$Ok(value);
			}

			return _Json_expecting('an INT', value);

		case 4:
			return (typeof value === 'number')
				? elm$core$Result$Ok(value)
				: _Json_expecting('a FLOAT', value);

		case 6:
			return (typeof value === 'string')
				? elm$core$Result$Ok(value)
				: (value instanceof String)
					? elm$core$Result$Ok(value + '')
					: _Json_expecting('a STRING', value);

		case 9:
			return (value === null)
				? elm$core$Result$Ok(decoder.c)
				: _Json_expecting('null', value);

		case 5:
			return elm$core$Result$Ok(_Json_wrap(value));

		case 7:
			if (!Array.isArray(value))
			{
				return _Json_expecting('a LIST', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _List_fromArray);

		case 8:
			if (!Array.isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _Json_toElmArray);

		case 10:
			var field = decoder.d;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_expecting('an OBJECT with a field named `' + field + '`', value);
			}
			var result = _Json_runHelp(decoder.b, value[field]);
			return (elm$core$Result$isOk(result)) ? result : elm$core$Result$Err(A2(elm$json$Json$Decode$Field, field, result.a));

		case 11:
			var index = decoder.e;
			if (!Array.isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			if (index >= value.length)
			{
				return _Json_expecting('a LONGER array. Need index ' + index + ' but only see ' + value.length + ' entries', value);
			}
			var result = _Json_runHelp(decoder.b, value[index]);
			return (elm$core$Result$isOk(result)) ? result : elm$core$Result$Err(A2(elm$json$Json$Decode$Index, index, result.a));

		case 12:
			if (typeof value !== 'object' || value === null || Array.isArray(value))
			{
				return _Json_expecting('an OBJECT', value);
			}

			var keyValuePairs = _List_Nil;
			// TODO test perf of Object.keys and switch when support is good enough
			for (var key in value)
			{
				if (value.hasOwnProperty(key))
				{
					var result = _Json_runHelp(decoder.b, value[key]);
					if (!elm$core$Result$isOk(result))
					{
						return elm$core$Result$Err(A2(elm$json$Json$Decode$Field, key, result.a));
					}
					keyValuePairs = _List_Cons(_Utils_Tuple2(key, result.a), keyValuePairs);
				}
			}
			return elm$core$Result$Ok(elm$core$List$reverse(keyValuePairs));

		case 13:
			var answer = decoder.f;
			var decoders = decoder.g;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (!elm$core$Result$isOk(result))
				{
					return result;
				}
				answer = answer(result.a);
			}
			return elm$core$Result$Ok(answer);

		case 14:
			var result = _Json_runHelp(decoder.b, value);
			return (!elm$core$Result$isOk(result))
				? result
				: _Json_runHelp(decoder.h(result.a), value);

		case 15:
			var errors = _List_Nil;
			for (var temp = decoder.g; temp.b; temp = temp.b) // WHILE_CONS
			{
				var result = _Json_runHelp(temp.a, value);
				if (elm$core$Result$isOk(result))
				{
					return result;
				}
				errors = _List_Cons(result.a, errors);
			}
			return elm$core$Result$Err(elm$json$Json$Decode$OneOf(elm$core$List$reverse(errors)));

		case 1:
			return elm$core$Result$Err(A2(elm$json$Json$Decode$Failure, decoder.a, _Json_wrap(value)));

		case 0:
			return elm$core$Result$Ok(decoder.a);
	}
}

function _Json_runArrayDecoder(decoder, value, toElmValue)
{
	var len = value.length;
	var array = new Array(len);
	for (var i = 0; i < len; i++)
	{
		var result = _Json_runHelp(decoder, value[i]);
		if (!elm$core$Result$isOk(result))
		{
			return elm$core$Result$Err(A2(elm$json$Json$Decode$Index, i, result.a));
		}
		array[i] = result.a;
	}
	return elm$core$Result$Ok(toElmValue(array));
}

function _Json_toElmArray(array)
{
	return A2(elm$core$Array$initialize, array.length, function(i) { return array[i]; });
}

function _Json_expecting(type, value)
{
	return elm$core$Result$Err(A2(elm$json$Json$Decode$Failure, 'Expecting ' + type, _Json_wrap(value)));
}


// EQUALITY

function _Json_equality(x, y)
{
	if (x === y)
	{
		return true;
	}

	if (x.$ !== y.$)
	{
		return false;
	}

	switch (x.$)
	{
		case 0:
		case 1:
			return x.a === y.a;

		case 3:
		case 2:
		case 4:
		case 6:
		case 5:
			return true;

		case 9:
			return x.c === y.c;

		case 7:
		case 8:
		case 12:
			return _Json_equality(x.b, y.b);

		case 10:
			return x.d === y.d && _Json_equality(x.b, y.b);

		case 11:
			return x.e === y.e && _Json_equality(x.b, y.b);

		case 13:
			return x.f === y.f && _Json_listEquality(x.g, y.g);

		case 14:
			return x.h === y.h && _Json_equality(x.b, y.b);

		case 15:
			return _Json_listEquality(x.g, y.g);
	}
}

function _Json_listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!_Json_equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

var _Json_encode = F2(function(indentLevel, value)
{
	return JSON.stringify(_Json_unwrap(value), null, indentLevel) + '';
});

function _Json_wrap_UNUSED(value) { return { $: 0, a: value }; }
function _Json_unwrap_UNUSED(value) { return value.a; }

function _Json_wrap(value) { return value; }
function _Json_unwrap(value) { return value; }

function _Json_emptyArray() { return []; }
function _Json_emptyObject() { return {}; }

var _Json_addField = F3(function(key, value, object)
{
	object[key] = _Json_unwrap(value);
	return object;
});

function _Json_addEntry(func)
{
	return F2(function(entry, array)
	{
		array.push(_Json_unwrap(func(entry)));
		return array;
	});
}

var _Json_encodeNull = _Json_wrap(null);



function _Process_sleep(time)
{
	return _Scheduler_binding(function(callback) {
		var id = setTimeout(function() {
			callback(_Scheduler_succeed(_Utils_Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}




// PROGRAMS


var _Platform_worker = F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.aO,
		impl.aZ,
		impl.aX,
		function() { return function() {} }
	);
});



// INITIALIZE A PROGRAM


function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder)
{
	var result = A2(_Json_run, flagDecoder, _Json_wrap(args ? args['flags'] : undefined));
	elm$core$Result$isOk(result) || _Debug_crash(2 /**_UNUSED/, _Json_errorToString(result.a) /**/);
	var managers = {};
	result = init(result.a);
	var model = result.a;
	var stepper = stepperBuilder(sendToApp, model);
	var ports = _Platform_setupEffects(managers, sendToApp);

	function sendToApp(msg, viewMetadata)
	{
		result = A2(update, msg, model);
		stepper(model = result.a, viewMetadata);
		_Platform_dispatchEffects(managers, result.b, subscriptions(model));
	}

	_Platform_dispatchEffects(managers, result.b, subscriptions(model));

	return ports ? { ports: ports } : {};
}



// TRACK PRELOADS
//
// This is used by code in elm/browser and elm/http
// to register any HTTP requests that are triggered by init.
//


var _Platform_preload;


function _Platform_registerPreload(url)
{
	_Platform_preload.add(url);
}



// EFFECT MANAGERS


var _Platform_effectManagers = {};


function _Platform_setupEffects(managers, sendToApp)
{
	var ports;

	// setup all necessary effect managers
	for (var key in _Platform_effectManagers)
	{
		var manager = _Platform_effectManagers[key];

		if (manager.a)
		{
			ports = ports || {};
			ports[key] = manager.a(key, sendToApp);
		}

		managers[key] = _Platform_instantiateManager(manager, sendToApp);
	}

	return ports;
}


function _Platform_createManager(init, onEffects, onSelfMsg, cmdMap, subMap)
{
	return {
		b: init,
		c: onEffects,
		d: onSelfMsg,
		e: cmdMap,
		f: subMap
	};
}


function _Platform_instantiateManager(info, sendToApp)
{
	var router = {
		g: sendToApp,
		h: undefined
	};

	var onEffects = info.c;
	var onSelfMsg = info.d;
	var cmdMap = info.e;
	var subMap = info.f;

	function loop(state)
	{
		return A2(_Scheduler_andThen, loop, _Scheduler_receive(function(msg)
		{
			var value = msg.a;

			if (msg.$ === 0)
			{
				return A3(onSelfMsg, router, value, state);
			}

			return cmdMap && subMap
				? A4(onEffects, router, value.i, value.j, state)
				: A3(onEffects, router, cmdMap ? value.i : value.j, state);
		}));
	}

	return router.h = _Scheduler_rawSpawn(A2(_Scheduler_andThen, loop, info.b));
}



// ROUTING


var _Platform_sendToApp = F2(function(router, msg)
{
	return _Scheduler_binding(function(callback)
	{
		router.g(msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});


var _Platform_sendToSelf = F2(function(router, msg)
{
	return A2(_Scheduler_send, router.h, {
		$: 0,
		a: msg
	});
});



// BAGS


function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: 1,
			k: home,
			l: value
		};
	};
}


function _Platform_batch(list)
{
	return {
		$: 2,
		m: list
	};
}


var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: 3,
		n: tagger,
		o: bag
	}
});



// PIPE BAGS INTO EFFECT MANAGERS


function _Platform_dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	_Platform_gatherEffects(true, cmdBag, effectsDict, null);
	_Platform_gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		_Scheduler_rawSend(managers[home], {
			$: 'fx',
			a: effectsDict[home] || { i: _List_Nil, j: _List_Nil }
		});
	}
}


function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case 1:
			var home = bag.k;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.l);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case 2:
			for (var list = bag.m; list.b; list = list.b) // WHILE_CONS
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
			}
			return;

		case 3:
			_Platform_gatherEffects(isCmd, bag.o, effectsDict, {
				p: bag.n,
				q: taggers
			});
			return;
	}
}


function _Platform_toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		for (var temp = taggers; temp; temp = temp.q)
		{
			x = temp.p(x);
		}
		return x;
	}

	var map = isCmd
		? _Platform_effectManagers[home].e
		: _Platform_effectManagers[home].f;

	return A2(map, applyTaggers, value)
}


function _Platform_insert(isCmd, newEffect, effects)
{
	effects = effects || { i: _List_Nil, j: _List_Nil };

	isCmd
		? (effects.i = _List_Cons(newEffect, effects.i))
		: (effects.j = _List_Cons(newEffect, effects.j));

	return effects;
}



// PORTS


function _Platform_checkPortName(name)
{
	if (_Platform_effectManagers[name])
	{
		_Debug_crash(3, name)
	}
}



// OUTGOING PORTS


function _Platform_outgoingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		e: _Platform_outgoingPortMap,
		r: converter,
		a: _Platform_setupOutgoingPort
	};
	return _Platform_leaf(name);
}


var _Platform_outgoingPortMap = F2(function(tagger, value) { return value; });


function _Platform_setupOutgoingPort(name)
{
	var subs = [];
	var converter = _Platform_effectManagers[name].r;

	// CREATE MANAGER

	var init = _Process_sleep(0);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, cmdList, state)
	{
		for ( ; cmdList.b; cmdList = cmdList.b) // WHILE_CONS
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = _Json_unwrap(converter(cmdList.a));
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
		}
		return init;
	});

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}



// INCOMING PORTS


function _Platform_incomingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		f: _Platform_incomingPortMap,
		r: converter,
		a: _Platform_setupIncomingPort
	};
	return _Platform_leaf(name);
}


var _Platform_incomingPortMap = F2(function(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});


function _Platform_setupIncomingPort(name, sendToApp)
{
	var subs = _List_Nil;
	var converter = _Platform_effectManagers[name].r;

	// CREATE MANAGER

	var init = _Scheduler_succeed(null);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, subList, state)
	{
		subs = subList;
		return init;
	});

	// PUBLIC API

	function send(incomingValue)
	{
		var result = A2(_Json_run, converter, _Json_wrap(incomingValue));

		elm$core$Result$isOk(result) || _Debug_crash(4, name, result.a);

		var value = result.a;
		for (var temp = subs; temp.b; temp = temp.b) // WHILE_CONS
		{
			sendToApp(temp.a(value));
		}
	}

	return { send: send };
}



// EXPORT ELM MODULES
//
// Have DEBUG and PROD versions so that we can (1) give nicer errors in
// debug mode and (2) not pay for the bits needed for that in prod mode.
//


function _Platform_export(exports)
{
	scope['Elm']
		? _Platform_mergeExportsProd(scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsProd(obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6)
				: _Platform_mergeExportsProd(obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}


function _Platform_export_UNUSED(exports)
{
	scope['Elm']
		? _Platform_mergeExportsDebug('Elm', scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsDebug(moduleName, obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6, moduleName)
				: _Platform_mergeExportsDebug(moduleName + '.' + name, obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}




// HELPERS


var _VirtualDom_divertHrefToApp;

var _VirtualDom_doc = typeof document !== 'undefined' ? document : {};


function _VirtualDom_appendChild(parent, child)
{
	parent.appendChild(child);
}

var _VirtualDom_init = F4(function(virtualNode, flagDecoder, debugMetadata, args)
{
	// NOTE: this function needs _Platform_export available to work

	/**/
	var node = args['node'];
	//*/
	/**_UNUSED/
	var node = args && args['node'] ? args['node'] : _Debug_crash(0);
	//*/

	node.parentNode.replaceChild(
		_VirtualDom_render(virtualNode, function() {}),
		node
	);

	return {};
});



// TEXT


function _VirtualDom_text(string)
{
	return {
		$: 0,
		a: string
	};
}



// NODE


var _VirtualDom_nodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 1,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_node = _VirtualDom_nodeNS(undefined);



// KEYED NODE


var _VirtualDom_keyedNodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 2,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_keyedNode = _VirtualDom_keyedNodeNS(undefined);



// CUSTOM


function _VirtualDom_custom(factList, model, render, diff)
{
	return {
		$: 3,
		d: _VirtualDom_organizeFacts(factList),
		g: model,
		h: render,
		i: diff
	};
}



// MAP


var _VirtualDom_map = F2(function(tagger, node)
{
	return {
		$: 4,
		j: tagger,
		k: node,
		b: 1 + (node.b || 0)
	};
});



// LAZY


function _VirtualDom_thunk(refs, thunk)
{
	return {
		$: 5,
		l: refs,
		m: thunk,
		k: undefined
	};
}

var _VirtualDom_lazy = F2(function(func, a)
{
	return _VirtualDom_thunk([func, a], function() {
		return func(a);
	});
});

var _VirtualDom_lazy2 = F3(function(func, a, b)
{
	return _VirtualDom_thunk([func, a, b], function() {
		return A2(func, a, b);
	});
});

var _VirtualDom_lazy3 = F4(function(func, a, b, c)
{
	return _VirtualDom_thunk([func, a, b, c], function() {
		return A3(func, a, b, c);
	});
});

var _VirtualDom_lazy4 = F5(function(func, a, b, c, d)
{
	return _VirtualDom_thunk([func, a, b, c, d], function() {
		return A4(func, a, b, c, d);
	});
});

var _VirtualDom_lazy5 = F6(function(func, a, b, c, d, e)
{
	return _VirtualDom_thunk([func, a, b, c, d, e], function() {
		return A5(func, a, b, c, d, e);
	});
});

var _VirtualDom_lazy6 = F7(function(func, a, b, c, d, e, f)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f], function() {
		return A6(func, a, b, c, d, e, f);
	});
});

var _VirtualDom_lazy7 = F8(function(func, a, b, c, d, e, f, g)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g], function() {
		return A7(func, a, b, c, d, e, f, g);
	});
});

var _VirtualDom_lazy8 = F9(function(func, a, b, c, d, e, f, g, h)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g, h], function() {
		return A8(func, a, b, c, d, e, f, g, h);
	});
});



// FACTS


var _VirtualDom_on = F2(function(key, handler)
{
	return {
		$: 'a0',
		n: key,
		o: handler
	};
});
var _VirtualDom_style = F2(function(key, value)
{
	return {
		$: 'a1',
		n: key,
		o: value
	};
});
var _VirtualDom_property = F2(function(key, value)
{
	return {
		$: 'a2',
		n: key,
		o: value
	};
});
var _VirtualDom_attribute = F2(function(key, value)
{
	return {
		$: 'a3',
		n: key,
		o: value
	};
});
var _VirtualDom_attributeNS = F3(function(namespace, key, value)
{
	return {
		$: 'a4',
		n: key,
		o: { f: namespace, o: value }
	};
});



// XSS ATTACK VECTOR CHECKS


function _VirtualDom_noScript(tag)
{
	return tag == 'script' ? 'p' : tag;
}

function _VirtualDom_noOnOrFormAction(key)
{
	return /^(on|formAction$)/i.test(key) ? 'data-' + key : key;
}

function _VirtualDom_noInnerHtmlOrFormAction(key)
{
	return key == 'innerHTML' || key == 'formAction' ? 'data-' + key : key;
}

function _VirtualDom_noJavaScriptUri(value)
{
	return /^javascript:/i.test(value.replace(/\s/g,'')) ? '' : value;
}

function _VirtualDom_noJavaScriptUri_UNUSED(value)
{
	return /^javascript:/i.test(value.replace(/\s/g,''))
		? 'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'
		: value;
}

function _VirtualDom_noJavaScriptOrHtmlUri(value)
{
	return /^\s*(javascript:|data:text\/html)/i.test(value) ? '' : value;
}

function _VirtualDom_noJavaScriptOrHtmlUri_UNUSED(value)
{
	return /^\s*(javascript:|data:text\/html)/i.test(value)
		? 'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'
		: value;
}



// MAP FACTS


var _VirtualDom_mapAttribute = F2(function(func, attr)
{
	return (attr.$ === 'a0')
		? A2(_VirtualDom_on, attr.n, _VirtualDom_mapHandler(func, attr.o))
		: attr;
});

function _VirtualDom_mapHandler(func, handler)
{
	var tag = elm$virtual_dom$VirtualDom$toHandlerInt(handler);

	// 0 = Normal
	// 1 = MayStopPropagation
	// 2 = MayPreventDefault
	// 3 = Custom

	return {
		$: handler.$,
		a:
			!tag
				? A2(elm$json$Json$Decode$map, func, handler.a)
				:
			A3(elm$json$Json$Decode$map2,
				tag < 3
					? _VirtualDom_mapEventTuple
					: _VirtualDom_mapEventRecord,
				elm$json$Json$Decode$succeed(func),
				handler.a
			)
	};
}

var _VirtualDom_mapEventTuple = F2(function(func, tuple)
{
	return _Utils_Tuple2(func(tuple.a), tuple.b);
});

var _VirtualDom_mapEventRecord = F2(function(func, record)
{
	return {
		r: func(record.r),
		ac: record.ac,
		_: record._
	}
});



// ORGANIZE FACTS


function _VirtualDom_organizeFacts(factList)
{
	for (var facts = {}; factList.b; factList = factList.b) // WHILE_CONS
	{
		var entry = factList.a;

		var tag = entry.$;
		var key = entry.n;
		var value = entry.o;

		if (tag === 'a2')
		{
			(key === 'className')
				? _VirtualDom_addClass(facts, key, _Json_unwrap(value))
				: facts[key] = _Json_unwrap(value);

			continue;
		}

		var subFacts = facts[tag] || (facts[tag] = {});
		(tag === 'a3' && key === 'class')
			? _VirtualDom_addClass(subFacts, key, value)
			: subFacts[key] = value;
	}

	return facts;
}

function _VirtualDom_addClass(object, key, newClass)
{
	var classes = object[key];
	object[key] = classes ? classes + ' ' + newClass : newClass;
}



// RENDER


function _VirtualDom_render(vNode, eventNode)
{
	var tag = vNode.$;

	if (tag === 5)
	{
		return _VirtualDom_render(vNode.k || (vNode.k = vNode.m()), eventNode);
	}

	if (tag === 0)
	{
		return _VirtualDom_doc.createTextNode(vNode.a);
	}

	if (tag === 4)
	{
		var subNode = vNode.k;
		var tagger = vNode.j;

		while (subNode.$ === 4)
		{
			typeof tagger !== 'object'
				? tagger = [tagger, subNode.j]
				: tagger.push(subNode.j);

			subNode = subNode.k;
		}

		var subEventRoot = { j: tagger, p: eventNode };
		var domNode = _VirtualDom_render(subNode, subEventRoot);
		domNode.elm_event_node_ref = subEventRoot;
		return domNode;
	}

	if (tag === 3)
	{
		var domNode = vNode.h(vNode.g);
		_VirtualDom_applyFacts(domNode, eventNode, vNode.d);
		return domNode;
	}

	// at this point `tag` must be 1 or 2

	var domNode = vNode.f
		? _VirtualDom_doc.createElementNS(vNode.f, vNode.c)
		: _VirtualDom_doc.createElement(vNode.c);

	if (_VirtualDom_divertHrefToApp && vNode.c == 'a')
	{
		domNode.addEventListener('click', _VirtualDom_divertHrefToApp(domNode));
	}

	_VirtualDom_applyFacts(domNode, eventNode, vNode.d);

	for (var kids = vNode.e, i = 0; i < kids.length; i++)
	{
		_VirtualDom_appendChild(domNode, _VirtualDom_render(tag === 1 ? kids[i] : kids[i].b, eventNode));
	}

	return domNode;
}



// APPLY FACTS


function _VirtualDom_applyFacts(domNode, eventNode, facts)
{
	for (var key in facts)
	{
		var value = facts[key];

		key === 'a1'
			? _VirtualDom_applyStyles(domNode, value)
			:
		key === 'a0'
			? _VirtualDom_applyEvents(domNode, eventNode, value)
			:
		key === 'a3'
			? _VirtualDom_applyAttrs(domNode, value)
			:
		key === 'a4'
			? _VirtualDom_applyAttrsNS(domNode, value)
			:
		(key !== 'value' || key !== 'checked' || domNode[key] !== value) && (domNode[key] = value);
	}
}



// APPLY STYLES


function _VirtualDom_applyStyles(domNode, styles)
{
	var domNodeStyle = domNode.style;

	for (var key in styles)
	{
		domNodeStyle[key] = styles[key];
	}
}



// APPLY ATTRS


function _VirtualDom_applyAttrs(domNode, attrs)
{
	for (var key in attrs)
	{
		var value = attrs[key];
		value
			? domNode.setAttribute(key, value)
			: domNode.removeAttribute(key);
	}
}



// APPLY NAMESPACED ATTRS


function _VirtualDom_applyAttrsNS(domNode, nsAttrs)
{
	for (var key in nsAttrs)
	{
		var pair = nsAttrs[key];
		var namespace = pair.f;
		var value = pair.o;

		value
			? domNode.setAttributeNS(namespace, key, value)
			: domNode.removeAttributeNS(namespace, key);
	}
}



// APPLY EVENTS


function _VirtualDom_applyEvents(domNode, eventNode, events)
{
	var allCallbacks = domNode.elmFs || (domNode.elmFs = {});

	for (var key in events)
	{
		var newHandler = events[key];
		var oldCallback = allCallbacks[key];

		if (!newHandler)
		{
			domNode.removeEventListener(key, oldCallback);
			allCallbacks[key] = undefined;
			continue;
		}

		if (oldCallback)
		{
			var oldHandler = oldCallback.q;
			if (oldHandler.$ === newHandler.$)
			{
				oldCallback.q = newHandler;
				continue;
			}
			domNode.removeEventListener(key, oldCallback);
		}

		oldCallback = _VirtualDom_makeCallback(eventNode, newHandler);
		domNode.addEventListener(key, oldCallback,
			_VirtualDom_passiveSupported
			&& { passive: elm$virtual_dom$VirtualDom$toHandlerInt(newHandler) < 2 }
		);
		allCallbacks[key] = oldCallback;
	}
}



// PASSIVE EVENTS


var _VirtualDom_passiveSupported;

try
{
	window.addEventListener('t', null, Object.defineProperty({}, 'passive', {
		get: function() { _VirtualDom_passiveSupported = true; }
	}));
}
catch(e) {}



// EVENT HANDLERS


function _VirtualDom_makeCallback(eventNode, initialHandler)
{
	function callback(event)
	{
		var handler = callback.q;
		var result = _Json_runHelp(handler.a, event);

		if (!elm$core$Result$isOk(result))
		{
			return;
		}

		var tag = elm$virtual_dom$VirtualDom$toHandlerInt(handler);

		// 0 = Normal
		// 1 = MayStopPropagation
		// 2 = MayPreventDefault
		// 3 = Custom

		var value = result.a;
		var message = !tag ? value : tag < 3 ? value.a : value.r;
		var stopPropagation = tag == 1 ? value.b : tag == 3 && value.ac;
		var currentEventNode = (
			stopPropagation && event.stopPropagation(),
			(tag == 2 ? value.b : tag == 3 && value._) && event.preventDefault(),
			eventNode
		);
		var tagger;
		var i;
		while (tagger = currentEventNode.j)
		{
			if (typeof tagger == 'function')
			{
				message = tagger(message);
			}
			else
			{
				for (var i = tagger.length; i--; )
				{
					message = tagger[i](message);
				}
			}
			currentEventNode = currentEventNode.p;
		}
		currentEventNode(message, stopPropagation); // stopPropagation implies isSync
	}

	callback.q = initialHandler;

	return callback;
}

function _VirtualDom_equalEvents(x, y)
{
	return x.$ == y.$ && _Json_equality(x.a, y.a);
}



// DIFF


// TODO: Should we do patches like in iOS?
//
// type Patch
//   = At Int Patch
//   | Batch (List Patch)
//   | Change ...
//
// How could it not be better?
//
function _VirtualDom_diff(x, y)
{
	var patches = [];
	_VirtualDom_diffHelp(x, y, patches, 0);
	return patches;
}


function _VirtualDom_pushPatch(patches, type, index, data)
{
	var patch = {
		$: type,
		r: index,
		s: data,
		t: undefined,
		u: undefined
	};
	patches.push(patch);
	return patch;
}


function _VirtualDom_diffHelp(x, y, patches, index)
{
	if (x === y)
	{
		return;
	}

	var xType = x.$;
	var yType = y.$;

	// Bail if you run into different types of nodes. Implies that the
	// structure has changed significantly and it's not worth a diff.
	if (xType !== yType)
	{
		if (xType === 1 && yType === 2)
		{
			y = _VirtualDom_dekey(y);
			yType = 1;
		}
		else
		{
			_VirtualDom_pushPatch(patches, 0, index, y);
			return;
		}
	}

	// Now we know that both nodes are the same $.
	switch (yType)
	{
		case 5:
			var xRefs = x.l;
			var yRefs = y.l;
			var i = xRefs.length;
			var same = i === yRefs.length;
			while (same && i--)
			{
				same = xRefs[i] === yRefs[i];
			}
			if (same)
			{
				y.k = x.k;
				return;
			}
			y.k = y.m();
			var subPatches = [];
			_VirtualDom_diffHelp(x.k, y.k, subPatches, 0);
			subPatches.length > 0 && _VirtualDom_pushPatch(patches, 1, index, subPatches);
			return;

		case 4:
			// gather nested taggers
			var xTaggers = x.j;
			var yTaggers = y.j;
			var nesting = false;

			var xSubNode = x.k;
			while (xSubNode.$ === 4)
			{
				nesting = true;

				typeof xTaggers !== 'object'
					? xTaggers = [xTaggers, xSubNode.j]
					: xTaggers.push(xSubNode.j);

				xSubNode = xSubNode.k;
			}

			var ySubNode = y.k;
			while (ySubNode.$ === 4)
			{
				nesting = true;

				typeof yTaggers !== 'object'
					? yTaggers = [yTaggers, ySubNode.j]
					: yTaggers.push(ySubNode.j);

				ySubNode = ySubNode.k;
			}

			// Just bail if different numbers of taggers. This implies the
			// structure of the virtual DOM has changed.
			if (nesting && xTaggers.length !== yTaggers.length)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			// check if taggers are "the same"
			if (nesting ? !_VirtualDom_pairwiseRefEqual(xTaggers, yTaggers) : xTaggers !== yTaggers)
			{
				_VirtualDom_pushPatch(patches, 2, index, yTaggers);
			}

			// diff everything below the taggers
			_VirtualDom_diffHelp(xSubNode, ySubNode, patches, index + 1);
			return;

		case 0:
			if (x.a !== y.a)
			{
				_VirtualDom_pushPatch(patches, 3, index, y.a);
			}
			return;

		case 1:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKids);
			return;

		case 2:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKeyedKids);
			return;

		case 3:
			if (x.h !== y.h)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
			factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

			var patch = y.i(x.g, y.g);
			patch && _VirtualDom_pushPatch(patches, 5, index, patch);

			return;
	}
}

// assumes the incoming arrays are the same length
function _VirtualDom_pairwiseRefEqual(as, bs)
{
	for (var i = 0; i < as.length; i++)
	{
		if (as[i] !== bs[i])
		{
			return false;
		}
	}

	return true;
}

function _VirtualDom_diffNodes(x, y, patches, index, diffKids)
{
	// Bail if obvious indicators have changed. Implies more serious
	// structural changes such that it's not worth it to diff.
	if (x.c !== y.c || x.f !== y.f)
	{
		_VirtualDom_pushPatch(patches, 0, index, y);
		return;
	}

	var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
	factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

	diffKids(x, y, patches, index);
}



// DIFF FACTS


// TODO Instead of creating a new diff object, it's possible to just test if
// there *is* a diff. During the actual patch, do the diff again and make the
// modifications directly. This way, there's no new allocations. Worth it?
function _VirtualDom_diffFacts(x, y, category)
{
	var diff;

	// look for changes and removals
	for (var xKey in x)
	{
		if (xKey === 'a1' || xKey === 'a0' || xKey === 'a3' || xKey === 'a4')
		{
			var subDiff = _VirtualDom_diffFacts(x[xKey], y[xKey] || {}, xKey);
			if (subDiff)
			{
				diff = diff || {};
				diff[xKey] = subDiff;
			}
			continue;
		}

		// remove if not in the new facts
		if (!(xKey in y))
		{
			diff = diff || {};
			diff[xKey] =
				!category
					? (typeof x[xKey] === 'string' ? '' : null)
					:
				(category === 'a1')
					? ''
					:
				(category === 'a0' || category === 'a3')
					? undefined
					:
				{ f: x[xKey].f, o: undefined };

			continue;
		}

		var xValue = x[xKey];
		var yValue = y[xKey];

		// reference equal, so don't worry about it
		if (xValue === yValue && xKey !== 'value' && xKey !== 'checked'
			|| category === 'a0' && _VirtualDom_equalEvents(xValue, yValue))
		{
			continue;
		}

		diff = diff || {};
		diff[xKey] = yValue;
	}

	// add new stuff
	for (var yKey in y)
	{
		if (!(yKey in x))
		{
			diff = diff || {};
			diff[yKey] = y[yKey];
		}
	}

	return diff;
}



// DIFF KIDS


function _VirtualDom_diffKids(xParent, yParent, patches, index)
{
	var xKids = xParent.e;
	var yKids = yParent.e;

	var xLen = xKids.length;
	var yLen = yKids.length;

	// FIGURE OUT IF THERE ARE INSERTS OR REMOVALS

	if (xLen > yLen)
	{
		_VirtualDom_pushPatch(patches, 6, index, {
			v: yLen,
			i: xLen - yLen
		});
	}
	else if (xLen < yLen)
	{
		_VirtualDom_pushPatch(patches, 7, index, {
			v: xLen,
			e: yKids
		});
	}

	// PAIRWISE DIFF EVERYTHING ELSE

	for (var minLen = xLen < yLen ? xLen : yLen, i = 0; i < minLen; i++)
	{
		var xKid = xKids[i];
		_VirtualDom_diffHelp(xKid, yKids[i], patches, ++index);
		index += xKid.b || 0;
	}
}



// KEYED DIFF


function _VirtualDom_diffKeyedKids(xParent, yParent, patches, rootIndex)
{
	var localPatches = [];

	var changes = {}; // Dict String Entry
	var inserts = []; // Array { index : Int, entry : Entry }
	// type Entry = { tag : String, vnode : VNode, index : Int, data : _ }

	var xKids = xParent.e;
	var yKids = yParent.e;
	var xLen = xKids.length;
	var yLen = yKids.length;
	var xIndex = 0;
	var yIndex = 0;

	var index = rootIndex;

	while (xIndex < xLen && yIndex < yLen)
	{
		var x = xKids[xIndex];
		var y = yKids[yIndex];

		var xKey = x.a;
		var yKey = y.a;
		var xNode = x.b;
		var yNode = y.b;

		// check if keys match

		if (xKey === yKey)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNode, localPatches, index);
			index += xNode.b || 0;

			xIndex++;
			yIndex++;
			continue;
		}

		// look ahead 1 to detect insertions and removals.

		var xNext = xKids[xIndex + 1];
		var yNext = yKids[yIndex + 1];

		if (xNext)
		{
			var xNextKey = xNext.a;
			var xNextNode = xNext.b;
			var oldMatch = yKey === xNextKey;
		}

		if (yNext)
		{
			var yNextKey = yNext.a;
			var yNextNode = yNext.b;
			var newMatch = xKey === yNextKey;
		}


		// swap x and y
		if (newMatch && oldMatch)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			_VirtualDom_insertNode(changes, localPatches, xKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNextNode, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		// insert y
		if (newMatch)
		{
			index++;
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			index += xNode.b || 0;

			xIndex += 1;
			yIndex += 2;
			continue;
		}

		// remove x
		if (oldMatch)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 1;
			continue;
		}

		// remove x, insert y
		if (xNext && xNextKey === yNextKey)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNextNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		break;
	}

	// eat up any remaining nodes with removeNode and insertNode

	while (xIndex < xLen)
	{
		index++;
		var x = xKids[xIndex];
		var xNode = x.b;
		_VirtualDom_removeNode(changes, localPatches, x.a, xNode, index);
		index += xNode.b || 0;
		xIndex++;
	}

	while (yIndex < yLen)
	{
		var endInserts = endInserts || [];
		var y = yKids[yIndex];
		_VirtualDom_insertNode(changes, localPatches, y.a, y.b, undefined, endInserts);
		yIndex++;
	}

	if (localPatches.length > 0 || inserts.length > 0 || endInserts)
	{
		_VirtualDom_pushPatch(patches, 8, rootIndex, {
			w: localPatches,
			x: inserts,
			y: endInserts
		});
	}
}



// CHANGES FROM KEYED DIFF


var _VirtualDom_POSTFIX = '_elmW6BL';


function _VirtualDom_insertNode(changes, localPatches, key, vnode, yIndex, inserts)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		entry = {
			c: 0,
			z: vnode,
			r: yIndex,
			s: undefined
		};

		inserts.push({ r: yIndex, A: entry });
		changes[key] = entry;

		return;
	}

	// this key was removed earlier, a match!
	if (entry.c === 1)
	{
		inserts.push({ r: yIndex, A: entry });

		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(entry.z, vnode, subPatches, entry.r);
		entry.r = yIndex;
		entry.s.s = {
			w: subPatches,
			A: entry
		};

		return;
	}

	// this key has already been inserted or moved, a duplicate!
	_VirtualDom_insertNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, yIndex, inserts);
}


function _VirtualDom_removeNode(changes, localPatches, key, vnode, index)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		var patch = _VirtualDom_pushPatch(localPatches, 9, index, undefined);

		changes[key] = {
			c: 1,
			z: vnode,
			r: index,
			s: patch
		};

		return;
	}

	// this key was inserted earlier, a match!
	if (entry.c === 0)
	{
		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(vnode, entry.z, subPatches, index);

		_VirtualDom_pushPatch(localPatches, 9, index, {
			w: subPatches,
			A: entry
		});

		return;
	}

	// this key has already been removed or moved, a duplicate!
	_VirtualDom_removeNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, index);
}



// ADD DOM NODES
//
// Each DOM node has an "index" assigned in order of traversal. It is important
// to minimize our crawl over the actual DOM, so these indexes (along with the
// descendantsCount of virtual nodes) let us skip touching entire subtrees of
// the DOM if we know there are no patches there.


function _VirtualDom_addDomNodes(domNode, vNode, patches, eventNode)
{
	_VirtualDom_addDomNodesHelp(domNode, vNode, patches, 0, 0, vNode.b, eventNode);
}


// assumes `patches` is non-empty and indexes increase monotonically.
function _VirtualDom_addDomNodesHelp(domNode, vNode, patches, i, low, high, eventNode)
{
	var patch = patches[i];
	var index = patch.r;

	while (index === low)
	{
		var patchType = patch.$;

		if (patchType === 1)
		{
			_VirtualDom_addDomNodes(domNode, vNode.k, patch.s, eventNode);
		}
		else if (patchType === 8)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var subPatches = patch.s.w;
			if (subPatches.length > 0)
			{
				_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
			}
		}
		else if (patchType === 9)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var data = patch.s;
			if (data)
			{
				data.A.s = domNode;
				var subPatches = data.w;
				if (subPatches.length > 0)
				{
					_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
				}
			}
		}
		else
		{
			patch.t = domNode;
			patch.u = eventNode;
		}

		i++;

		if (!(patch = patches[i]) || (index = patch.r) > high)
		{
			return i;
		}
	}

	var tag = vNode.$;

	if (tag === 4)
	{
		var subNode = vNode.k;

		while (subNode.$ === 4)
		{
			subNode = subNode.k;
		}

		return _VirtualDom_addDomNodesHelp(domNode, subNode, patches, i, low + 1, high, domNode.elm_event_node_ref);
	}

	// tag must be 1 or 2 at this point

	var vKids = vNode.e;
	var childNodes = domNode.childNodes;
	for (var j = 0; j < vKids.length; j++)
	{
		low++;
		var vKid = tag === 1 ? vKids[j] : vKids[j].b;
		var nextLow = low + (vKid.b || 0);
		if (low <= index && index <= nextLow)
		{
			i = _VirtualDom_addDomNodesHelp(childNodes[j], vKid, patches, i, low, nextLow, eventNode);
			if (!(patch = patches[i]) || (index = patch.r) > high)
			{
				return i;
			}
		}
		low = nextLow;
	}
	return i;
}



// APPLY PATCHES


function _VirtualDom_applyPatches(rootDomNode, oldVirtualNode, patches, eventNode)
{
	if (patches.length === 0)
	{
		return rootDomNode;
	}

	_VirtualDom_addDomNodes(rootDomNode, oldVirtualNode, patches, eventNode);
	return _VirtualDom_applyPatchesHelp(rootDomNode, patches);
}

function _VirtualDom_applyPatchesHelp(rootDomNode, patches)
{
	for (var i = 0; i < patches.length; i++)
	{
		var patch = patches[i];
		var localDomNode = patch.t
		var newNode = _VirtualDom_applyPatch(localDomNode, patch);
		if (localDomNode === rootDomNode)
		{
			rootDomNode = newNode;
		}
	}
	return rootDomNode;
}

function _VirtualDom_applyPatch(domNode, patch)
{
	switch (patch.$)
	{
		case 0:
			return _VirtualDom_applyPatchRedraw(domNode, patch.s, patch.u);

		case 4:
			_VirtualDom_applyFacts(domNode, patch.u, patch.s);
			return domNode;

		case 3:
			domNode.replaceData(0, domNode.length, patch.s);
			return domNode;

		case 1:
			return _VirtualDom_applyPatchesHelp(domNode, patch.s);

		case 2:
			if (domNode.elm_event_node_ref)
			{
				domNode.elm_event_node_ref.j = patch.s;
			}
			else
			{
				domNode.elm_event_node_ref = { j: patch.s, p: patch.u };
			}
			return domNode;

		case 6:
			var data = patch.s;
			for (var i = 0; i < data.i; i++)
			{
				domNode.removeChild(domNode.childNodes[data.v]);
			}
			return domNode;

		case 7:
			var data = patch.s;
			var kids = data.e;
			var i = data.v;
			var theEnd = domNode.childNodes[i];
			for (; i < kids.length; i++)
			{
				domNode.insertBefore(_VirtualDom_render(kids[i], patch.u), theEnd);
			}
			return domNode;

		case 9:
			var data = patch.s;
			if (!data)
			{
				domNode.parentNode.removeChild(domNode);
				return domNode;
			}
			var entry = data.A;
			if (typeof entry.r !== 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
			}
			entry.s = _VirtualDom_applyPatchesHelp(domNode, data.w);
			return domNode;

		case 8:
			return _VirtualDom_applyPatchReorder(domNode, patch);

		case 5:
			return patch.s(domNode);

		default:
			_Debug_crash(10); // 'Ran into an unknown patch!'
	}
}


function _VirtualDom_applyPatchRedraw(domNode, vNode, eventNode)
{
	var parentNode = domNode.parentNode;
	var newNode = _VirtualDom_render(vNode, eventNode);

	if (!newNode.elm_event_node_ref)
	{
		newNode.elm_event_node_ref = domNode.elm_event_node_ref;
	}

	if (parentNode && newNode !== domNode)
	{
		parentNode.replaceChild(newNode, domNode);
	}
	return newNode;
}


function _VirtualDom_applyPatchReorder(domNode, patch)
{
	var data = patch.s;

	// remove end inserts
	var frag = _VirtualDom_applyPatchReorderEndInsertsHelp(data.y, patch);

	// removals
	domNode = _VirtualDom_applyPatchesHelp(domNode, data.w);

	// inserts
	var inserts = data.x;
	for (var i = 0; i < inserts.length; i++)
	{
		var insert = inserts[i];
		var entry = insert.A;
		var node = entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u);
		domNode.insertBefore(node, domNode.childNodes[insert.r]);
	}

	// add end inserts
	if (frag)
	{
		_VirtualDom_appendChild(domNode, frag);
	}

	return domNode;
}


function _VirtualDom_applyPatchReorderEndInsertsHelp(endInserts, patch)
{
	if (!endInserts)
	{
		return;
	}

	var frag = _VirtualDom_doc.createDocumentFragment();
	for (var i = 0; i < endInserts.length; i++)
	{
		var insert = endInserts[i];
		var entry = insert.A;
		_VirtualDom_appendChild(frag, entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u)
		);
	}
	return frag;
}


function _VirtualDom_virtualize(node)
{
	// TEXT NODES

	if (node.nodeType === 3)
	{
		return _VirtualDom_text(node.textContent);
	}


	// WEIRD NODES

	if (node.nodeType !== 1)
	{
		return _VirtualDom_text('');
	}


	// ELEMENT NODES

	var attrList = _List_Nil;
	var attrs = node.attributes;
	for (var i = attrs.length; i--; )
	{
		var attr = attrs[i];
		var name = attr.name;
		var value = attr.value;
		attrList = _List_Cons( A2(_VirtualDom_attribute, name, value), attrList );
	}

	var tag = node.tagName.toLowerCase();
	var kidList = _List_Nil;
	var kids = node.childNodes;

	for (var i = kids.length; i--; )
	{
		kidList = _List_Cons(_VirtualDom_virtualize(kids[i]), kidList);
	}
	return A3(_VirtualDom_node, tag, attrList, kidList);
}

function _VirtualDom_dekey(keyedNode)
{
	var keyedKids = keyedNode.e;
	var len = keyedKids.length;
	var kids = new Array(len);
	for (var i = 0; i < len; i++)
	{
		kids[i] = keyedKids[i].b;
	}

	return {
		$: 1,
		c: keyedNode.c,
		d: keyedNode.d,
		e: kids,
		f: keyedNode.f,
		b: keyedNode.b
	};
}



// ELEMENT


var _Debugger_element;

var _Browser_element = _Debugger_element || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.aO,
		impl.aZ,
		impl.aX,
		function(sendToApp, initialModel) {
			var view = impl.a$;
			/**/
			var domNode = args['node'];
			//*/
			/**_UNUSED/
			var domNode = args && args['node'] ? args['node'] : _Debug_crash(0);
			//*/
			var currNode = _VirtualDom_virtualize(domNode);

			return _Browser_makeAnimator(initialModel, function(model)
			{
				var nextNode = view(model);
				var patches = _VirtualDom_diff(currNode, nextNode);
				domNode = _VirtualDom_applyPatches(domNode, currNode, patches, sendToApp);
				currNode = nextNode;
			});
		}
	);
});



// DOCUMENT


var _Debugger_document;

var _Browser_document = _Debugger_document || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.aO,
		impl.aZ,
		impl.aX,
		function(sendToApp, initialModel) {
			var divertHrefToApp = impl.M && impl.M(sendToApp)
			var view = impl.a$;
			var title = _VirtualDom_doc.title;
			var bodyNode = _VirtualDom_doc.body;
			var currNode = _VirtualDom_virtualize(bodyNode);
			return _Browser_makeAnimator(initialModel, function(model)
			{
				_VirtualDom_divertHrefToApp = divertHrefToApp;
				var doc = view(model);
				var nextNode = _VirtualDom_node('body')(_List_Nil)(doc.aH);
				var patches = _VirtualDom_diff(currNode, nextNode);
				bodyNode = _VirtualDom_applyPatches(bodyNode, currNode, patches, sendToApp);
				currNode = nextNode;
				_VirtualDom_divertHrefToApp = 0;
				(title !== doc.aY) && (_VirtualDom_doc.title = title = doc.aY);
			});
		}
	);
});



// ANIMATION


var _Browser_requestAnimationFrame =
	typeof requestAnimationFrame !== 'undefined'
		? requestAnimationFrame
		: function(callback) { setTimeout(callback, 1000 / 60); };


function _Browser_makeAnimator(model, draw)
{
	draw(model);

	var state = 0;

	function updateIfNeeded()
	{
		state = state === 1
			? 0
			: ( _Browser_requestAnimationFrame(updateIfNeeded), draw(model), 1 );
	}

	return function(nextModel, isSync)
	{
		model = nextModel;

		isSync
			? ( draw(model),
				state === 2 && (state = 1)
				)
			: ( state === 0 && _Browser_requestAnimationFrame(updateIfNeeded),
				state = 2
				);
	};
}



// APPLICATION


function _Browser_application(impl)
{
	var onUrlChange = impl.aT;
	var onUrlRequest = impl.aU;
	var key = function() { key.a(onUrlChange(_Browser_getUrl())); };

	return _Browser_document({
		M: function(sendToApp)
		{
			key.a = sendToApp;
			_Browser_window.addEventListener('popstate', key);
			_Browser_window.navigator.userAgent.indexOf('Trident') < 0 || _Browser_window.addEventListener('hashchange', key);

			return F2(function(domNode, event)
			{
				if (!event.ctrlKey && !event.metaKey && !event.shiftKey && event.button < 1 && !domNode.target && !domNode.download)
				{
					event.preventDefault();
					var href = domNode.href;
					var curr = _Browser_getUrl();
					var next = elm$url$Url$fromString(href).a;
					sendToApp(onUrlRequest(
						(next
							&& curr.ax === next.ax
							&& curr.am === next.am
							&& curr.au.a === next.au.a
						)
							? elm$browser$Browser$Internal(next)
							: elm$browser$Browser$External(href)
					));
				}
			});
		},
		aO: function(flags)
		{
			return A3(impl.aO, flags, _Browser_getUrl(), key);
		},
		a$: impl.a$,
		aZ: impl.aZ,
		aX: impl.aX
	});
}

function _Browser_getUrl()
{
	return elm$url$Url$fromString(_VirtualDom_doc.location.href).a || _Debug_crash(1);
}

var _Browser_go = F2(function(key, n)
{
	return A2(elm$core$Task$perform, elm$core$Basics$never, _Scheduler_binding(function() {
		n && history.go(n);
		key();
	}));
});

var _Browser_pushUrl = F2(function(key, url)
{
	return A2(elm$core$Task$perform, elm$core$Basics$never, _Scheduler_binding(function() {
		history.pushState({}, '', url);
		key();
	}));
});

var _Browser_replaceUrl = F2(function(key, url)
{
	return A2(elm$core$Task$perform, elm$core$Basics$never, _Scheduler_binding(function() {
		history.replaceState({}, '', url);
		key();
	}));
});



// GLOBAL EVENTS


var _Browser_fakeNode = { addEventListener: function() {}, removeEventListener: function() {} };
var _Browser_doc = typeof document !== 'undefined' ? document : _Browser_fakeNode;
var _Browser_window = typeof window !== 'undefined' ? window : _Browser_fakeNode;

var _Browser_on = F3(function(node, eventName, sendToSelf)
{
	return _Scheduler_spawn(_Scheduler_binding(function(callback)
	{
		function handler(event)	{ _Scheduler_rawSpawn(sendToSelf(event)); }
		node.addEventListener(eventName, handler, _VirtualDom_passiveSupported && { passive: true });
		return function() { node.removeEventListener(eventName, handler); };
	}));
});

var _Browser_decodeEvent = F2(function(decoder, event)
{
	var result = _Json_runHelp(decoder, event);
	return elm$core$Result$isOk(result) ? elm$core$Maybe$Just(result.a) : elm$core$Maybe$Nothing;
});



// PAGE VISIBILITY


function _Browser_visibilityInfo()
{
	return (typeof _VirtualDom_doc.hidden !== 'undefined')
		? { aM: 'hidden', J: 'visibilitychange' }
		:
	(typeof _VirtualDom_doc.mozHidden !== 'undefined')
		? { aM: 'mozHidden', J: 'mozvisibilitychange' }
		:
	(typeof _VirtualDom_doc.msHidden !== 'undefined')
		? { aM: 'msHidden', J: 'msvisibilitychange' }
		:
	(typeof _VirtualDom_doc.webkitHidden !== 'undefined')
		? { aM: 'webkitHidden', J: 'webkitvisibilitychange' }
		: { aM: 'hidden', J: 'visibilitychange' };
}



// ANIMATION FRAMES


function _Browser_rAF()
{
	return _Scheduler_binding(function(callback)
	{
		var id = requestAnimationFrame(function() {
			callback(_Scheduler_succeed(Date.now()));
		});

		return function() {
			cancelAnimationFrame(id);
		};
	});
}


function _Browser_now()
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(Date.now()));
	});
}



// DOM STUFF


function _Browser_withNode(id, doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			var node = document.getElementById(id);
			callback(node
				? _Scheduler_succeed(doStuff(node))
				: _Scheduler_fail(elm$browser$Browser$Dom$NotFound(id))
			);
		});
	});
}


function _Browser_withWindow(doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(doStuff()));
		});
	});
}


// FOCUS and BLUR


var _Browser_call = F2(function(functionName, id)
{
	return _Browser_withNode(id, function(node) {
		node[functionName]();
		return _Utils_Tuple0;
	});
});



// WINDOW VIEWPORT


function _Browser_getViewport()
{
	return {
		aB: _Browser_getScene(),
		aE: {
			W: _Browser_window.pageXOffset,
			X: _Browser_window.pageYOffset,
			H: _Browser_doc.documentElement.clientWidth,
			B: _Browser_doc.documentElement.clientHeight
		}
	};
}

function _Browser_getScene()
{
	var body = _Browser_doc.body;
	var elem = _Browser_doc.documentElement;
	return {
		H: Math.max(body.scrollWidth, body.offsetWidth, elem.scrollWidth, elem.offsetWidth, elem.clientWidth),
		B: Math.max(body.scrollHeight, body.offsetHeight, elem.scrollHeight, elem.offsetHeight, elem.clientHeight)
	};
}

var _Browser_setViewport = F2(function(x, y)
{
	return _Browser_withWindow(function()
	{
		_Browser_window.scroll(x, y);
		return _Utils_Tuple0;
	});
});



// ELEMENT VIEWPORT


function _Browser_getViewportOf(id)
{
	return _Browser_withNode(id, function(node)
	{
		return {
			aB: {
				H: node.scrollWidth,
				B: node.scrollHeight
			},
			aE: {
				W: node.scrollLeft,
				X: node.scrollTop,
				H: node.clientWidth,
				B: node.clientHeight
			}
		};
	});
}


var _Browser_setViewportOf = F3(function(id, x, y)
{
	return _Browser_withNode(id, function(node)
	{
		node.scrollLeft = x;
		node.scrollTop = y;
		return _Utils_Tuple0;
	});
});



// ELEMENT


function _Browser_getElement(id)
{
	return _Browser_withNode(id, function(node)
	{
		var rect = node.getBoundingClientRect();
		var x = _Browser_window.pageXOffset;
		var y = _Browser_window.pageYOffset;
		return {
			aB: _Browser_getScene(),
			aE: {
				W: x,
				X: y,
				H: _Browser_doc.documentElement.clientWidth,
				B: _Browser_doc.documentElement.clientHeight
			},
			aJ: {
				W: x + rect.left,
				X: y + rect.top,
				H: rect.width,
				B: rect.height
			}
		};
	});
}



// LOAD and RELOAD


function _Browser_reload(skipCache)
{
	return A2(elm$core$Task$perform, elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		_VirtualDom_doc.location.reload(skipCache);
	}));
}

function _Browser_load(url)
{
	return A2(elm$core$Task$perform, elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		try
		{
			_Browser_window.location = url;
		}
		catch(err)
		{
			// Only Firefox can throw a NS_ERROR_MALFORMED_URI exception here.
			// Other browsers reload the page, so let's be consistent about that.
			_VirtualDom_doc.location.reload(false);
		}
	}));
}



function _Time_now(millisToPosix)
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(millisToPosix(Date.now())));
	});
}

var _Time_setInterval = F2(function(interval, task)
{
	return _Scheduler_binding(function(callback)
	{
		var id = setInterval(function() { _Scheduler_rawSpawn(task); }, interval);
		return function() { clearInterval(id); };
	});
});

function _Time_here()
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(
			A2(elm$time$Time$customZone, -(new Date().getTimezoneOffset()), _List_Nil)
		));
	});
}


function _Time_getZoneName()
{
	return _Scheduler_binding(function(callback)
	{
		try
		{
			var name = elm$time$Time$Name(Intl.DateTimeFormat().resolvedOptions().timeZone);
		}
		catch (e)
		{
			var name = elm$time$Time$Offset(new Date().getTimezoneOffset());
		}
		callback(_Scheduler_succeed(name));
	});
}



var _Bitwise_and = F2(function(a, b)
{
	return a & b;
});

var _Bitwise_or = F2(function(a, b)
{
	return a | b;
});

var _Bitwise_xor = F2(function(a, b)
{
	return a ^ b;
});

function _Bitwise_complement(a)
{
	return ~a;
};

var _Bitwise_shiftLeftBy = F2(function(offset, a)
{
	return a << offset;
});

var _Bitwise_shiftRightBy = F2(function(offset, a)
{
	return a >> offset;
});

var _Bitwise_shiftRightZfBy = F2(function(offset, a)
{
	return a >>> offset;
});
var author$project$Main$Selecting = {$: 0};
var author$project$Main$OneMsg = function (a) {
	return {$: 0, a: a};
};
var author$project$Main$TwoMsg = function (a) {
	return {$: 1, a: a};
};
var author$project$OnePlayer$GameMsg = function (a) {
	return {$: 2, a: a};
};
var author$project$OnePlayer$MenuMsg = function (a) {
	return {$: 0, a: a};
};
var author$project$Bottle$KeyDown = function (a) {
	return {$: 1, a: a};
};
var author$project$Bottle$SetGoal = function (a) {
	return {$: 4, a: a};
};
var author$project$Bottle$TickTock = function (a) {
	return {$: 2, a: a};
};
var author$project$Bottle$tickForSpeed = function (speed) {
	switch (speed) {
		case 2:
			return 300;
		case 1:
			return 700;
		default:
			return 1000;
	}
};
var elm$browser$Browser$Events$Document = 0;
var elm$browser$Browser$Events$MySub = F3(
	function (a, b, c) {
		return {$: 0, a: a, b: b, c: c};
	});
var elm$browser$Browser$Events$State = F2(
	function (subs, pids) {
		return {at: pids, aC: subs};
	});
var elm$core$Dict$RBEmpty_elm_builtin = {$: -2};
var elm$core$Dict$empty = elm$core$Dict$RBEmpty_elm_builtin;
var elm$core$Elm$JsArray$foldr = _JsArray_foldr;
var elm$core$Array$foldr = F3(
	function (func, baseCase, _n0) {
		var tree = _n0.c;
		var tail = _n0.d;
		var helper = F2(
			function (node, acc) {
				if (!node.$) {
					var subTree = node.a;
					return A3(elm$core$Elm$JsArray$foldr, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3(elm$core$Elm$JsArray$foldr, func, acc, values);
				}
			});
		return A3(
			elm$core$Elm$JsArray$foldr,
			helper,
			A3(elm$core$Elm$JsArray$foldr, func, baseCase, tail),
			tree);
	});
var elm$core$Basics$EQ = 1;
var elm$core$Basics$LT = 0;
var elm$core$List$cons = _List_cons;
var elm$core$Array$toList = function (array) {
	return A3(elm$core$Array$foldr, elm$core$List$cons, _List_Nil, array);
};
var elm$core$Basics$GT = 2;
var elm$core$Dict$foldr = F3(
	function (func, acc, t) {
		foldr:
		while (true) {
			if (t.$ === -2) {
				return acc;
			} else {
				var key = t.b;
				var value = t.c;
				var left = t.d;
				var right = t.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3(elm$core$Dict$foldr, func, acc, right)),
					$temp$t = left;
				func = $temp$func;
				acc = $temp$acc;
				t = $temp$t;
				continue foldr;
			}
		}
	});
var elm$core$Dict$toList = function (dict) {
	return A3(
		elm$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var elm$core$Dict$keys = function (dict) {
	return A3(
		elm$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return A2(elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var elm$core$Set$toList = function (_n0) {
	var dict = _n0;
	return elm$core$Dict$keys(dict);
};
var elm$core$Task$succeed = _Scheduler_succeed;
var elm$browser$Browser$Events$init = elm$core$Task$succeed(
	A2(elm$browser$Browser$Events$State, _List_Nil, elm$core$Dict$empty));
var elm$browser$Browser$Events$nodeToKey = function (node) {
	if (!node) {
		return 'd_';
	} else {
		return 'w_';
	}
};
var elm$core$Basics$append = _Utils_append;
var elm$browser$Browser$Events$addKey = function (sub) {
	var node = sub.a;
	var name = sub.b;
	return _Utils_Tuple2(
		_Utils_ap(
			elm$browser$Browser$Events$nodeToKey(node),
			name),
		sub);
};
var elm$browser$Browser$Events$Event = F2(
	function (key, event) {
		return {aj: event, an: key};
	});
var elm$core$Basics$apL = F2(
	function (f, x) {
		return f(x);
	});
var elm$core$Basics$False = 1;
var elm$core$Basics$True = 0;
var elm$core$Result$isOk = function (result) {
	if (!result.$) {
		return true;
	} else {
		return false;
	}
};
var elm$core$Array$branchFactor = 32;
var elm$core$Array$Array_elm_builtin = F4(
	function (a, b, c, d) {
		return {$: 0, a: a, b: b, c: c, d: d};
	});
var elm$core$Basics$ceiling = _Basics_ceiling;
var elm$core$Basics$fdiv = _Basics_fdiv;
var elm$core$Basics$logBase = F2(
	function (base, number) {
		return _Basics_log(number) / _Basics_log(base);
	});
var elm$core$Basics$toFloat = _Basics_toFloat;
var elm$core$Array$shiftStep = elm$core$Basics$ceiling(
	A2(elm$core$Basics$logBase, 2, elm$core$Array$branchFactor));
var elm$core$Elm$JsArray$empty = _JsArray_empty;
var elm$core$Array$empty = A4(elm$core$Array$Array_elm_builtin, 0, elm$core$Array$shiftStep, elm$core$Elm$JsArray$empty, elm$core$Elm$JsArray$empty);
var elm$core$Array$Leaf = function (a) {
	return {$: 1, a: a};
};
var elm$core$Array$SubTree = function (a) {
	return {$: 0, a: a};
};
var elm$core$Elm$JsArray$initializeFromList = _JsArray_initializeFromList;
var elm$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			if (!list.b) {
				return acc;
			} else {
				var x = list.a;
				var xs = list.b;
				var $temp$func = func,
					$temp$acc = A2(func, x, acc),
					$temp$list = xs;
				func = $temp$func;
				acc = $temp$acc;
				list = $temp$list;
				continue foldl;
			}
		}
	});
var elm$core$List$reverse = function (list) {
	return A3(elm$core$List$foldl, elm$core$List$cons, _List_Nil, list);
};
var elm$core$Array$compressNodes = F2(
	function (nodes, acc) {
		compressNodes:
		while (true) {
			var _n0 = A2(elm$core$Elm$JsArray$initializeFromList, elm$core$Array$branchFactor, nodes);
			var node = _n0.a;
			var remainingNodes = _n0.b;
			var newAcc = A2(
				elm$core$List$cons,
				elm$core$Array$SubTree(node),
				acc);
			if (!remainingNodes.b) {
				return elm$core$List$reverse(newAcc);
			} else {
				var $temp$nodes = remainingNodes,
					$temp$acc = newAcc;
				nodes = $temp$nodes;
				acc = $temp$acc;
				continue compressNodes;
			}
		}
	});
var elm$core$Basics$apR = F2(
	function (x, f) {
		return f(x);
	});
var elm$core$Basics$eq = _Utils_equal;
var elm$core$Tuple$first = function (_n0) {
	var x = _n0.a;
	return x;
};
var elm$core$Array$treeFromBuilder = F2(
	function (nodeList, nodeListSize) {
		treeFromBuilder:
		while (true) {
			var newNodeSize = elm$core$Basics$ceiling(nodeListSize / elm$core$Array$branchFactor);
			if (newNodeSize === 1) {
				return A2(elm$core$Elm$JsArray$initializeFromList, elm$core$Array$branchFactor, nodeList).a;
			} else {
				var $temp$nodeList = A2(elm$core$Array$compressNodes, nodeList, _List_Nil),
					$temp$nodeListSize = newNodeSize;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue treeFromBuilder;
			}
		}
	});
var elm$core$Basics$add = _Basics_add;
var elm$core$Basics$floor = _Basics_floor;
var elm$core$Basics$gt = _Utils_gt;
var elm$core$Basics$max = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) > 0) ? x : y;
	});
var elm$core$Basics$mul = _Basics_mul;
var elm$core$Basics$sub = _Basics_sub;
var elm$core$Elm$JsArray$length = _JsArray_length;
var elm$core$Array$builderToArray = F2(
	function (reverseNodeList, builder) {
		if (!builder.c) {
			return A4(
				elm$core$Array$Array_elm_builtin,
				elm$core$Elm$JsArray$length(builder.f),
				elm$core$Array$shiftStep,
				elm$core$Elm$JsArray$empty,
				builder.f);
		} else {
			var treeLen = builder.c * elm$core$Array$branchFactor;
			var depth = elm$core$Basics$floor(
				A2(elm$core$Basics$logBase, elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? elm$core$List$reverse(builder.h) : builder.h;
			var tree = A2(elm$core$Array$treeFromBuilder, correctNodeList, builder.c);
			return A4(
				elm$core$Array$Array_elm_builtin,
				elm$core$Elm$JsArray$length(builder.f) + treeLen,
				A2(elm$core$Basics$max, 5, depth * elm$core$Array$shiftStep),
				tree,
				builder.f);
		}
	});
var elm$core$Basics$idiv = _Basics_idiv;
var elm$core$Basics$lt = _Utils_lt;
var elm$core$Elm$JsArray$initialize = _JsArray_initialize;
var elm$core$Array$initializeHelp = F5(
	function (fn, fromIndex, len, nodeList, tail) {
		initializeHelp:
		while (true) {
			if (fromIndex < 0) {
				return A2(
					elm$core$Array$builderToArray,
					false,
					{h: nodeList, c: (len / elm$core$Array$branchFactor) | 0, f: tail});
			} else {
				var leaf = elm$core$Array$Leaf(
					A3(elm$core$Elm$JsArray$initialize, elm$core$Array$branchFactor, fromIndex, fn));
				var $temp$fn = fn,
					$temp$fromIndex = fromIndex - elm$core$Array$branchFactor,
					$temp$len = len,
					$temp$nodeList = A2(elm$core$List$cons, leaf, nodeList),
					$temp$tail = tail;
				fn = $temp$fn;
				fromIndex = $temp$fromIndex;
				len = $temp$len;
				nodeList = $temp$nodeList;
				tail = $temp$tail;
				continue initializeHelp;
			}
		}
	});
var elm$core$Basics$le = _Utils_le;
var elm$core$Basics$remainderBy = _Basics_remainderBy;
var elm$core$Array$initialize = F2(
	function (len, fn) {
		if (len <= 0) {
			return elm$core$Array$empty;
		} else {
			var tailLen = len % elm$core$Array$branchFactor;
			var tail = A3(elm$core$Elm$JsArray$initialize, tailLen, len - tailLen, fn);
			var initialFromIndex = (len - tailLen) - elm$core$Array$branchFactor;
			return A5(elm$core$Array$initializeHelp, fn, initialFromIndex, len, _List_Nil, tail);
		}
	});
var elm$core$Maybe$Just = function (a) {
	return {$: 0, a: a};
};
var elm$core$Maybe$Nothing = {$: 1};
var elm$core$Result$Err = function (a) {
	return {$: 1, a: a};
};
var elm$core$Result$Ok = function (a) {
	return {$: 0, a: a};
};
var elm$json$Json$Decode$Failure = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var elm$json$Json$Decode$Field = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var elm$json$Json$Decode$Index = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var elm$json$Json$Decode$OneOf = function (a) {
	return {$: 2, a: a};
};
var elm$core$Basics$and = _Basics_and;
var elm$core$Basics$or = _Basics_or;
var elm$core$Char$toCode = _Char_toCode;
var elm$core$Char$isLower = function (_char) {
	var code = elm$core$Char$toCode(_char);
	return (97 <= code) && (code <= 122);
};
var elm$core$Char$isUpper = function (_char) {
	var code = elm$core$Char$toCode(_char);
	return (code <= 90) && (65 <= code);
};
var elm$core$Char$isAlpha = function (_char) {
	return elm$core$Char$isLower(_char) || elm$core$Char$isUpper(_char);
};
var elm$core$Char$isDigit = function (_char) {
	var code = elm$core$Char$toCode(_char);
	return (code <= 57) && (48 <= code);
};
var elm$core$Char$isAlphaNum = function (_char) {
	return elm$core$Char$isLower(_char) || (elm$core$Char$isUpper(_char) || elm$core$Char$isDigit(_char));
};
var elm$core$List$length = function (xs) {
	return A3(
		elm$core$List$foldl,
		F2(
			function (_n0, i) {
				return i + 1;
			}),
		0,
		xs);
};
var elm$core$List$map2 = _List_map2;
var elm$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_Utils_cmp(lo, hi) < 1) {
				var $temp$lo = lo,
					$temp$hi = hi - 1,
					$temp$list = A2(elm$core$List$cons, hi, list);
				lo = $temp$lo;
				hi = $temp$hi;
				list = $temp$list;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var elm$core$List$range = F2(
	function (lo, hi) {
		return A3(elm$core$List$rangeHelp, lo, hi, _List_Nil);
	});
var elm$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			elm$core$List$map2,
			f,
			A2(
				elm$core$List$range,
				0,
				elm$core$List$length(xs) - 1),
			xs);
	});
var elm$core$String$all = _String_all;
var elm$core$String$fromInt = _String_fromNumber;
var elm$core$String$join = F2(
	function (sep, chunks) {
		return A2(
			_String_join,
			sep,
			_List_toArray(chunks));
	});
var elm$core$String$uncons = _String_uncons;
var elm$core$String$split = F2(
	function (sep, string) {
		return _List_fromArray(
			A2(_String_split, sep, string));
	});
var elm$json$Json$Decode$indent = function (str) {
	return A2(
		elm$core$String$join,
		'\n    ',
		A2(elm$core$String$split, '\n', str));
};
var elm$json$Json$Encode$encode = _Json_encode;
var elm$json$Json$Decode$errorOneOf = F2(
	function (i, error) {
		return '\n\n(' + (elm$core$String$fromInt(i + 1) + (') ' + elm$json$Json$Decode$indent(
			elm$json$Json$Decode$errorToString(error))));
	});
var elm$json$Json$Decode$errorToString = function (error) {
	return A2(elm$json$Json$Decode$errorToStringHelp, error, _List_Nil);
};
var elm$json$Json$Decode$errorToStringHelp = F2(
	function (error, context) {
		errorToStringHelp:
		while (true) {
			switch (error.$) {
				case 0:
					var f = error.a;
					var err = error.b;
					var isSimple = function () {
						var _n1 = elm$core$String$uncons(f);
						if (_n1.$ === 1) {
							return false;
						} else {
							var _n2 = _n1.a;
							var _char = _n2.a;
							var rest = _n2.b;
							return elm$core$Char$isAlpha(_char) && A2(elm$core$String$all, elm$core$Char$isAlphaNum, rest);
						}
					}();
					var fieldName = isSimple ? ('.' + f) : ('[\'' + (f + '\']'));
					var $temp$error = err,
						$temp$context = A2(elm$core$List$cons, fieldName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 1:
					var i = error.a;
					var err = error.b;
					var indexName = '[' + (elm$core$String$fromInt(i) + ']');
					var $temp$error = err,
						$temp$context = A2(elm$core$List$cons, indexName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 2:
					var errors = error.a;
					if (!errors.b) {
						return 'Ran into a Json.Decode.oneOf with no possibilities' + function () {
							if (!context.b) {
								return '!';
							} else {
								return ' at json' + A2(
									elm$core$String$join,
									'',
									elm$core$List$reverse(context));
							}
						}();
					} else {
						if (!errors.b.b) {
							var err = errors.a;
							var $temp$error = err,
								$temp$context = context;
							error = $temp$error;
							context = $temp$context;
							continue errorToStringHelp;
						} else {
							var starter = function () {
								if (!context.b) {
									return 'Json.Decode.oneOf';
								} else {
									return 'The Json.Decode.oneOf at json' + A2(
										elm$core$String$join,
										'',
										elm$core$List$reverse(context));
								}
							}();
							var introduction = starter + (' failed in the following ' + (elm$core$String$fromInt(
								elm$core$List$length(errors)) + ' ways:'));
							return A2(
								elm$core$String$join,
								'\n\n',
								A2(
									elm$core$List$cons,
									introduction,
									A2(elm$core$List$indexedMap, elm$json$Json$Decode$errorOneOf, errors)));
						}
					}
				default:
					var msg = error.a;
					var json = error.b;
					var introduction = function () {
						if (!context.b) {
							return 'Problem with the given value:\n\n';
						} else {
							return 'Problem with the value at json' + (A2(
								elm$core$String$join,
								'',
								elm$core$List$reverse(context)) + ':\n\n    ');
						}
					}();
					return introduction + (elm$json$Json$Decode$indent(
						A2(elm$json$Json$Encode$encode, 4, json)) + ('\n\n' + msg));
			}
		}
	});
var elm$core$Platform$sendToSelf = _Platform_sendToSelf;
var elm$core$Task$andThen = _Scheduler_andThen;
var elm$core$Task$map = F2(
	function (func, taskA) {
		return A2(
			elm$core$Task$andThen,
			function (a) {
				return elm$core$Task$succeed(
					func(a));
			},
			taskA);
	});
var elm$browser$Browser$External = function (a) {
	return {$: 1, a: a};
};
var elm$browser$Browser$Internal = function (a) {
	return {$: 0, a: a};
};
var elm$browser$Browser$Dom$NotFound = elm$core$Basics$identity;
var elm$core$Basics$never = function (_n0) {
	never:
	while (true) {
		var nvr = _n0;
		var $temp$_n0 = nvr;
		_n0 = $temp$_n0;
		continue never;
	}
};
var elm$core$Basics$identity = function (x) {
	return x;
};
var elm$core$Task$Perform = elm$core$Basics$identity;
var elm$core$Task$init = elm$core$Task$succeed(0);
var elm$core$List$foldrHelper = F4(
	function (fn, acc, ctr, ls) {
		if (!ls.b) {
			return acc;
		} else {
			var a = ls.a;
			var r1 = ls.b;
			if (!r1.b) {
				return A2(fn, a, acc);
			} else {
				var b = r1.a;
				var r2 = r1.b;
				if (!r2.b) {
					return A2(
						fn,
						a,
						A2(fn, b, acc));
				} else {
					var c = r2.a;
					var r3 = r2.b;
					if (!r3.b) {
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(fn, c, acc)));
					} else {
						var d = r3.a;
						var r4 = r3.b;
						var res = (ctr > 500) ? A3(
							elm$core$List$foldl,
							fn,
							acc,
							elm$core$List$reverse(r4)) : A4(elm$core$List$foldrHelper, fn, acc, ctr + 1, r4);
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(
									fn,
									c,
									A2(fn, d, res))));
					}
				}
			}
		}
	});
var elm$core$List$foldr = F3(
	function (fn, acc, ls) {
		return A4(elm$core$List$foldrHelper, fn, acc, 0, ls);
	});
var elm$core$List$map = F2(
	function (f, xs) {
		return A3(
			elm$core$List$foldr,
			F2(
				function (x, acc) {
					return A2(
						elm$core$List$cons,
						f(x),
						acc);
				}),
			_List_Nil,
			xs);
	});
var elm$core$Task$map2 = F3(
	function (func, taskA, taskB) {
		return A2(
			elm$core$Task$andThen,
			function (a) {
				return A2(
					elm$core$Task$andThen,
					function (b) {
						return elm$core$Task$succeed(
							A2(func, a, b));
					},
					taskB);
			},
			taskA);
	});
var elm$core$Task$sequence = function (tasks) {
	return A3(
		elm$core$List$foldr,
		elm$core$Task$map2(elm$core$List$cons),
		elm$core$Task$succeed(_List_Nil),
		tasks);
};
var elm$core$Platform$sendToApp = _Platform_sendToApp;
var elm$core$Task$spawnCmd = F2(
	function (router, _n0) {
		var task = _n0;
		return _Scheduler_spawn(
			A2(
				elm$core$Task$andThen,
				elm$core$Platform$sendToApp(router),
				task));
	});
var elm$core$Task$onEffects = F3(
	function (router, commands, state) {
		return A2(
			elm$core$Task$map,
			function (_n0) {
				return 0;
			},
			elm$core$Task$sequence(
				A2(
					elm$core$List$map,
					elm$core$Task$spawnCmd(router),
					commands)));
	});
var elm$core$Task$onSelfMsg = F3(
	function (_n0, _n1, _n2) {
		return elm$core$Task$succeed(0);
	});
var elm$core$Task$cmdMap = F2(
	function (tagger, _n0) {
		var task = _n0;
		return A2(elm$core$Task$map, tagger, task);
	});
_Platform_effectManagers['Task'] = _Platform_createManager(elm$core$Task$init, elm$core$Task$onEffects, elm$core$Task$onSelfMsg, elm$core$Task$cmdMap);
var elm$core$Task$command = _Platform_leaf('Task');
var elm$core$Task$perform = F2(
	function (toMessage, task) {
		return elm$core$Task$command(
			A2(elm$core$Task$map, toMessage, task));
	});
var elm$json$Json$Decode$map = _Json_map1;
var elm$json$Json$Decode$map2 = _Json_map2;
var elm$json$Json$Decode$succeed = _Json_succeed;
var elm$virtual_dom$VirtualDom$toHandlerInt = function (handler) {
	switch (handler.$) {
		case 0:
			return 0;
		case 1:
			return 1;
		case 2:
			return 2;
		default:
			return 3;
	}
};
var elm$core$String$length = _String_length;
var elm$core$String$slice = _String_slice;
var elm$core$String$dropLeft = F2(
	function (n, string) {
		return (n < 1) ? string : A3(
			elm$core$String$slice,
			n,
			elm$core$String$length(string),
			string);
	});
var elm$core$String$startsWith = _String_startsWith;
var elm$url$Url$Http = 0;
var elm$url$Url$Https = 1;
var elm$core$String$indexes = _String_indexes;
var elm$core$String$isEmpty = function (string) {
	return string === '';
};
var elm$core$String$left = F2(
	function (n, string) {
		return (n < 1) ? '' : A3(elm$core$String$slice, 0, n, string);
	});
var elm$core$String$contains = _String_contains;
var elm$core$String$toInt = _String_toInt;
var elm$url$Url$Url = F6(
	function (protocol, host, port_, path, query, fragment) {
		return {ak: fragment, am: host, as: path, au: port_, ax: protocol, ay: query};
	});
var elm$url$Url$chompBeforePath = F5(
	function (protocol, path, params, frag, str) {
		if (elm$core$String$isEmpty(str) || A2(elm$core$String$contains, '@', str)) {
			return elm$core$Maybe$Nothing;
		} else {
			var _n0 = A2(elm$core$String$indexes, ':', str);
			if (!_n0.b) {
				return elm$core$Maybe$Just(
					A6(elm$url$Url$Url, protocol, str, elm$core$Maybe$Nothing, path, params, frag));
			} else {
				if (!_n0.b.b) {
					var i = _n0.a;
					var _n1 = elm$core$String$toInt(
						A2(elm$core$String$dropLeft, i + 1, str));
					if (_n1.$ === 1) {
						return elm$core$Maybe$Nothing;
					} else {
						var port_ = _n1;
						return elm$core$Maybe$Just(
							A6(
								elm$url$Url$Url,
								protocol,
								A2(elm$core$String$left, i, str),
								port_,
								path,
								params,
								frag));
					}
				} else {
					return elm$core$Maybe$Nothing;
				}
			}
		}
	});
var elm$url$Url$chompBeforeQuery = F4(
	function (protocol, params, frag, str) {
		if (elm$core$String$isEmpty(str)) {
			return elm$core$Maybe$Nothing;
		} else {
			var _n0 = A2(elm$core$String$indexes, '/', str);
			if (!_n0.b) {
				return A5(elm$url$Url$chompBeforePath, protocol, '/', params, frag, str);
			} else {
				var i = _n0.a;
				return A5(
					elm$url$Url$chompBeforePath,
					protocol,
					A2(elm$core$String$dropLeft, i, str),
					params,
					frag,
					A2(elm$core$String$left, i, str));
			}
		}
	});
var elm$url$Url$chompBeforeFragment = F3(
	function (protocol, frag, str) {
		if (elm$core$String$isEmpty(str)) {
			return elm$core$Maybe$Nothing;
		} else {
			var _n0 = A2(elm$core$String$indexes, '?', str);
			if (!_n0.b) {
				return A4(elm$url$Url$chompBeforeQuery, protocol, elm$core$Maybe$Nothing, frag, str);
			} else {
				var i = _n0.a;
				return A4(
					elm$url$Url$chompBeforeQuery,
					protocol,
					elm$core$Maybe$Just(
						A2(elm$core$String$dropLeft, i + 1, str)),
					frag,
					A2(elm$core$String$left, i, str));
			}
		}
	});
var elm$url$Url$chompAfterProtocol = F2(
	function (protocol, str) {
		if (elm$core$String$isEmpty(str)) {
			return elm$core$Maybe$Nothing;
		} else {
			var _n0 = A2(elm$core$String$indexes, '#', str);
			if (!_n0.b) {
				return A3(elm$url$Url$chompBeforeFragment, protocol, elm$core$Maybe$Nothing, str);
			} else {
				var i = _n0.a;
				return A3(
					elm$url$Url$chompBeforeFragment,
					protocol,
					elm$core$Maybe$Just(
						A2(elm$core$String$dropLeft, i + 1, str)),
					A2(elm$core$String$left, i, str));
			}
		}
	});
var elm$url$Url$fromString = function (str) {
	return A2(elm$core$String$startsWith, 'http://', str) ? A2(
		elm$url$Url$chompAfterProtocol,
		0,
		A2(elm$core$String$dropLeft, 7, str)) : (A2(elm$core$String$startsWith, 'https://', str) ? A2(
		elm$url$Url$chompAfterProtocol,
		1,
		A2(elm$core$String$dropLeft, 8, str)) : elm$core$Maybe$Nothing);
};
var elm$browser$Browser$Events$spawn = F3(
	function (router, key, _n0) {
		var node = _n0.a;
		var name = _n0.b;
		var actualNode = function () {
			if (!node) {
				return _Browser_doc;
			} else {
				return _Browser_window;
			}
		}();
		return A2(
			elm$core$Task$map,
			function (value) {
				return _Utils_Tuple2(key, value);
			},
			A3(
				_Browser_on,
				actualNode,
				name,
				function (event) {
					return A2(
						elm$core$Platform$sendToSelf,
						router,
						A2(elm$browser$Browser$Events$Event, key, event));
				}));
	});
var elm$core$Dict$Black = 1;
var elm$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {$: -1, a: a, b: b, c: c, d: d, e: e};
	});
var elm$core$Basics$compare = _Utils_compare;
var elm$core$Dict$Red = 0;
var elm$core$Dict$balance = F5(
	function (color, key, value, left, right) {
		if ((right.$ === -1) && (!right.a)) {
			var _n1 = right.a;
			var rK = right.b;
			var rV = right.c;
			var rLeft = right.d;
			var rRight = right.e;
			if ((left.$ === -1) && (!left.a)) {
				var _n3 = left.a;
				var lK = left.b;
				var lV = left.c;
				var lLeft = left.d;
				var lRight = left.e;
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					0,
					key,
					value,
					A5(elm$core$Dict$RBNode_elm_builtin, 1, lK, lV, lLeft, lRight),
					A5(elm$core$Dict$RBNode_elm_builtin, 1, rK, rV, rLeft, rRight));
			} else {
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					color,
					rK,
					rV,
					A5(elm$core$Dict$RBNode_elm_builtin, 0, key, value, left, rLeft),
					rRight);
			}
		} else {
			if ((((left.$ === -1) && (!left.a)) && (left.d.$ === -1)) && (!left.d.a)) {
				var _n5 = left.a;
				var lK = left.b;
				var lV = left.c;
				var _n6 = left.d;
				var _n7 = _n6.a;
				var llK = _n6.b;
				var llV = _n6.c;
				var llLeft = _n6.d;
				var llRight = _n6.e;
				var lRight = left.e;
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					0,
					lK,
					lV,
					A5(elm$core$Dict$RBNode_elm_builtin, 1, llK, llV, llLeft, llRight),
					A5(elm$core$Dict$RBNode_elm_builtin, 1, key, value, lRight, right));
			} else {
				return A5(elm$core$Dict$RBNode_elm_builtin, color, key, value, left, right);
			}
		}
	});
var elm$core$Dict$insertHelp = F3(
	function (key, value, dict) {
		if (dict.$ === -2) {
			return A5(elm$core$Dict$RBNode_elm_builtin, 0, key, value, elm$core$Dict$RBEmpty_elm_builtin, elm$core$Dict$RBEmpty_elm_builtin);
		} else {
			var nColor = dict.a;
			var nKey = dict.b;
			var nValue = dict.c;
			var nLeft = dict.d;
			var nRight = dict.e;
			var _n1 = A2(elm$core$Basics$compare, key, nKey);
			switch (_n1) {
				case 0:
					return A5(
						elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						A3(elm$core$Dict$insertHelp, key, value, nLeft),
						nRight);
				case 1:
					return A5(elm$core$Dict$RBNode_elm_builtin, nColor, nKey, value, nLeft, nRight);
				default:
					return A5(
						elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						nLeft,
						A3(elm$core$Dict$insertHelp, key, value, nRight));
			}
		}
	});
var elm$core$Dict$insert = F3(
	function (key, value, dict) {
		var _n0 = A3(elm$core$Dict$insertHelp, key, value, dict);
		if ((_n0.$ === -1) && (!_n0.a)) {
			var _n1 = _n0.a;
			var k = _n0.b;
			var v = _n0.c;
			var l = _n0.d;
			var r = _n0.e;
			return A5(elm$core$Dict$RBNode_elm_builtin, 1, k, v, l, r);
		} else {
			var x = _n0;
			return x;
		}
	});
var elm$core$Dict$fromList = function (assocs) {
	return A3(
		elm$core$List$foldl,
		F2(
			function (_n0, dict) {
				var key = _n0.a;
				var value = _n0.b;
				return A3(elm$core$Dict$insert, key, value, dict);
			}),
		elm$core$Dict$empty,
		assocs);
};
var elm$core$Dict$foldl = F3(
	function (func, acc, dict) {
		foldl:
		while (true) {
			if (dict.$ === -2) {
				return acc;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3(elm$core$Dict$foldl, func, acc, left)),
					$temp$dict = right;
				func = $temp$func;
				acc = $temp$acc;
				dict = $temp$dict;
				continue foldl;
			}
		}
	});
var elm$core$Dict$merge = F6(
	function (leftStep, bothStep, rightStep, leftDict, rightDict, initialResult) {
		var stepState = F3(
			function (rKey, rValue, _n0) {
				stepState:
				while (true) {
					var list = _n0.a;
					var result = _n0.b;
					if (!list.b) {
						return _Utils_Tuple2(
							list,
							A3(rightStep, rKey, rValue, result));
					} else {
						var _n2 = list.a;
						var lKey = _n2.a;
						var lValue = _n2.b;
						var rest = list.b;
						if (_Utils_cmp(lKey, rKey) < 0) {
							var $temp$rKey = rKey,
								$temp$rValue = rValue,
								$temp$_n0 = _Utils_Tuple2(
								rest,
								A3(leftStep, lKey, lValue, result));
							rKey = $temp$rKey;
							rValue = $temp$rValue;
							_n0 = $temp$_n0;
							continue stepState;
						} else {
							if (_Utils_cmp(lKey, rKey) > 0) {
								return _Utils_Tuple2(
									list,
									A3(rightStep, rKey, rValue, result));
							} else {
								return _Utils_Tuple2(
									rest,
									A4(bothStep, lKey, lValue, rValue, result));
							}
						}
					}
				}
			});
		var _n3 = A3(
			elm$core$Dict$foldl,
			stepState,
			_Utils_Tuple2(
				elm$core$Dict$toList(leftDict),
				initialResult),
			rightDict);
		var leftovers = _n3.a;
		var intermediateResult = _n3.b;
		return A3(
			elm$core$List$foldl,
			F2(
				function (_n4, result) {
					var k = _n4.a;
					var v = _n4.b;
					return A3(leftStep, k, v, result);
				}),
			intermediateResult,
			leftovers);
	});
var elm$core$Dict$union = F2(
	function (t1, t2) {
		return A3(elm$core$Dict$foldl, elm$core$Dict$insert, t2, t1);
	});
var elm$core$Process$kill = _Scheduler_kill;
var elm$browser$Browser$Events$onEffects = F3(
	function (router, subs, state) {
		var stepRight = F3(
			function (key, sub, _n6) {
				var deads = _n6.a;
				var lives = _n6.b;
				var news = _n6.c;
				return _Utils_Tuple3(
					deads,
					lives,
					A2(
						elm$core$List$cons,
						A3(elm$browser$Browser$Events$spawn, router, key, sub),
						news));
			});
		var stepLeft = F3(
			function (_n4, pid, _n5) {
				var deads = _n5.a;
				var lives = _n5.b;
				var news = _n5.c;
				return _Utils_Tuple3(
					A2(elm$core$List$cons, pid, deads),
					lives,
					news);
			});
		var stepBoth = F4(
			function (key, pid, _n2, _n3) {
				var deads = _n3.a;
				var lives = _n3.b;
				var news = _n3.c;
				return _Utils_Tuple3(
					deads,
					A3(elm$core$Dict$insert, key, pid, lives),
					news);
			});
		var newSubs = A2(elm$core$List$map, elm$browser$Browser$Events$addKey, subs);
		var _n0 = A6(
			elm$core$Dict$merge,
			stepLeft,
			stepBoth,
			stepRight,
			state.at,
			elm$core$Dict$fromList(newSubs),
			_Utils_Tuple3(_List_Nil, elm$core$Dict$empty, _List_Nil));
		var deadPids = _n0.a;
		var livePids = _n0.b;
		var makeNewPids = _n0.c;
		return A2(
			elm$core$Task$andThen,
			function (pids) {
				return elm$core$Task$succeed(
					A2(
						elm$browser$Browser$Events$State,
						newSubs,
						A2(
							elm$core$Dict$union,
							livePids,
							elm$core$Dict$fromList(pids))));
			},
			A2(
				elm$core$Task$andThen,
				function (_n1) {
					return elm$core$Task$sequence(makeNewPids);
				},
				elm$core$Task$sequence(
					A2(elm$core$List$map, elm$core$Process$kill, deadPids))));
	});
var elm$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _n0 = f(mx);
		if (!_n0.$) {
			var x = _n0.a;
			return A2(elm$core$List$cons, x, xs);
		} else {
			return xs;
		}
	});
var elm$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			elm$core$List$foldr,
			elm$core$List$maybeCons(f),
			_List_Nil,
			xs);
	});
var elm$browser$Browser$Events$onSelfMsg = F3(
	function (router, _n0, state) {
		var key = _n0.an;
		var event = _n0.aj;
		var toMessage = function (_n2) {
			var subKey = _n2.a;
			var _n3 = _n2.b;
			var node = _n3.a;
			var name = _n3.b;
			var decoder = _n3.c;
			return _Utils_eq(subKey, key) ? A2(_Browser_decodeEvent, decoder, event) : elm$core$Maybe$Nothing;
		};
		var messages = A2(elm$core$List$filterMap, toMessage, state.aC);
		return A2(
			elm$core$Task$andThen,
			function (_n1) {
				return elm$core$Task$succeed(state);
			},
			elm$core$Task$sequence(
				A2(
					elm$core$List$map,
					elm$core$Platform$sendToApp(router),
					messages)));
	});
var elm$browser$Browser$Events$subMap = F2(
	function (func, _n0) {
		var node = _n0.a;
		var name = _n0.b;
		var decoder = _n0.c;
		return A3(
			elm$browser$Browser$Events$MySub,
			node,
			name,
			A2(elm$json$Json$Decode$map, func, decoder));
	});
_Platform_effectManagers['Browser.Events'] = _Platform_createManager(elm$browser$Browser$Events$init, elm$browser$Browser$Events$onEffects, elm$browser$Browser$Events$onSelfMsg, 0, elm$browser$Browser$Events$subMap);
var elm$browser$Browser$Events$subscription = _Platform_leaf('Browser.Events');
var elm$browser$Browser$Events$on = F3(
	function (node, name, decoder) {
		return elm$browser$Browser$Events$subscription(
			A3(elm$browser$Browser$Events$MySub, node, name, decoder));
	});
var elm$browser$Browser$Events$onKeyDown = A2(elm$browser$Browser$Events$on, 0, 'keydown');
var elm$core$Basics$composeR = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var elm$core$Platform$Sub$batch = _Platform_batch;
var elm$json$Json$Decode$field = _Json_decodeField;
var elm$json$Json$Decode$int = _Json_decodeInt;
var elm$html$Html$Events$keyCode = A2(elm$json$Json$Decode$field, 'keyCode', elm$json$Json$Decode$int);
var elm$time$Time$Every = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var elm$time$Time$State = F2(
	function (taggers, processes) {
		return {aw: processes, aD: taggers};
	});
var elm$time$Time$init = elm$core$Task$succeed(
	A2(elm$time$Time$State, elm$core$Dict$empty, elm$core$Dict$empty));
var elm$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			if (dict.$ === -2) {
				return elm$core$Maybe$Nothing;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var _n1 = A2(elm$core$Basics$compare, targetKey, key);
				switch (_n1) {
					case 0:
						var $temp$targetKey = targetKey,
							$temp$dict = left;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
					case 1:
						return elm$core$Maybe$Just(value);
					default:
						var $temp$targetKey = targetKey,
							$temp$dict = right;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
				}
			}
		}
	});
var elm$time$Time$addMySub = F2(
	function (_n0, state) {
		var interval = _n0.a;
		var tagger = _n0.b;
		var _n1 = A2(elm$core$Dict$get, interval, state);
		if (_n1.$ === 1) {
			return A3(
				elm$core$Dict$insert,
				interval,
				_List_fromArray(
					[tagger]),
				state);
		} else {
			var taggers = _n1.a;
			return A3(
				elm$core$Dict$insert,
				interval,
				A2(elm$core$List$cons, tagger, taggers),
				state);
		}
	});
var elm$core$Process$spawn = _Scheduler_spawn;
var elm$time$Time$Name = function (a) {
	return {$: 0, a: a};
};
var elm$time$Time$Offset = function (a) {
	return {$: 1, a: a};
};
var elm$time$Time$Zone = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var elm$time$Time$customZone = elm$time$Time$Zone;
var elm$time$Time$setInterval = _Time_setInterval;
var elm$time$Time$spawnHelp = F3(
	function (router, intervals, processes) {
		if (!intervals.b) {
			return elm$core$Task$succeed(processes);
		} else {
			var interval = intervals.a;
			var rest = intervals.b;
			var spawnTimer = elm$core$Process$spawn(
				A2(
					elm$time$Time$setInterval,
					interval,
					A2(elm$core$Platform$sendToSelf, router, interval)));
			var spawnRest = function (id) {
				return A3(
					elm$time$Time$spawnHelp,
					router,
					rest,
					A3(elm$core$Dict$insert, interval, id, processes));
			};
			return A2(elm$core$Task$andThen, spawnRest, spawnTimer);
		}
	});
var elm$time$Time$onEffects = F3(
	function (router, subs, _n0) {
		var processes = _n0.aw;
		var rightStep = F3(
			function (_n6, id, _n7) {
				var spawns = _n7.a;
				var existing = _n7.b;
				var kills = _n7.c;
				return _Utils_Tuple3(
					spawns,
					existing,
					A2(
						elm$core$Task$andThen,
						function (_n5) {
							return kills;
						},
						elm$core$Process$kill(id)));
			});
		var newTaggers = A3(elm$core$List$foldl, elm$time$Time$addMySub, elm$core$Dict$empty, subs);
		var leftStep = F3(
			function (interval, taggers, _n4) {
				var spawns = _n4.a;
				var existing = _n4.b;
				var kills = _n4.c;
				return _Utils_Tuple3(
					A2(elm$core$List$cons, interval, spawns),
					existing,
					kills);
			});
		var bothStep = F4(
			function (interval, taggers, id, _n3) {
				var spawns = _n3.a;
				var existing = _n3.b;
				var kills = _n3.c;
				return _Utils_Tuple3(
					spawns,
					A3(elm$core$Dict$insert, interval, id, existing),
					kills);
			});
		var _n1 = A6(
			elm$core$Dict$merge,
			leftStep,
			bothStep,
			rightStep,
			newTaggers,
			processes,
			_Utils_Tuple3(
				_List_Nil,
				elm$core$Dict$empty,
				elm$core$Task$succeed(0)));
		var spawnList = _n1.a;
		var existingDict = _n1.b;
		var killTask = _n1.c;
		return A2(
			elm$core$Task$andThen,
			function (newProcesses) {
				return elm$core$Task$succeed(
					A2(elm$time$Time$State, newTaggers, newProcesses));
			},
			A2(
				elm$core$Task$andThen,
				function (_n2) {
					return A3(elm$time$Time$spawnHelp, router, spawnList, existingDict);
				},
				killTask));
	});
var elm$time$Time$Posix = elm$core$Basics$identity;
var elm$time$Time$millisToPosix = elm$core$Basics$identity;
var elm$time$Time$now = _Time_now(elm$time$Time$millisToPosix);
var elm$time$Time$onSelfMsg = F3(
	function (router, interval, state) {
		var _n0 = A2(elm$core$Dict$get, interval, state.aD);
		if (_n0.$ === 1) {
			return elm$core$Task$succeed(state);
		} else {
			var taggers = _n0.a;
			var tellTaggers = function (time) {
				return elm$core$Task$sequence(
					A2(
						elm$core$List$map,
						function (tagger) {
							return A2(
								elm$core$Platform$sendToApp,
								router,
								tagger(time));
						},
						taggers));
			};
			return A2(
				elm$core$Task$andThen,
				function (_n1) {
					return elm$core$Task$succeed(state);
				},
				A2(elm$core$Task$andThen, tellTaggers, elm$time$Time$now));
		}
	});
var elm$core$Basics$composeL = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var elm$time$Time$subMap = F2(
	function (f, _n0) {
		var interval = _n0.a;
		var tagger = _n0.b;
		return A2(
			elm$time$Time$Every,
			interval,
			A2(elm$core$Basics$composeL, f, tagger));
	});
_Platform_effectManagers['Time'] = _Platform_createManager(elm$time$Time$init, elm$time$Time$onEffects, elm$time$Time$onSelfMsg, 0, elm$time$Time$subMap);
var elm$time$Time$subscription = _Platform_leaf('Time');
var elm$time$Time$every = F2(
	function (interval, tagger) {
		return elm$time$Time$subscription(
			A2(elm$time$Time$Every, interval, tagger));
	});
var author$project$Bottle$subscriptions = F2(
	function (speed, model) {
		return elm$core$Platform$Sub$batch(
			_List_fromArray(
				[
					A2(
					elm$time$Time$every,
					author$project$Bottle$tickForSpeed(speed),
					author$project$Bottle$TickTock),
					function () {
					var _n0 = model.R;
					if (!_n0.$) {
						var controls = _n0.a;
						return elm$browser$Browser$Events$onKeyDown(
							A2(
								elm$json$Json$Decode$map,
								A2(elm$core$Basics$composeR, controls, author$project$Bottle$KeyDown),
								elm$html$Html$Events$keyCode));
					} else {
						var bot = _n0.a;
						var direction = A2(bot, model.a, model.i);
						return A2(
							elm$time$Time$every,
							author$project$Bottle$tickForSpeed(speed) / 4,
							function (_n1) {
								return author$project$Bottle$SetGoal(direction);
							});
					}
				}()
				]));
	});
var author$project$OnePlayer$Game$BottleMsg = function (a) {
	return {$: 0, a: a};
};
var elm$core$Platform$Sub$map = _Platform_map;
var elm$core$Platform$Sub$none = elm$core$Platform$Sub$batch(_List_Nil);
var author$project$OnePlayer$Game$subscriptions = function (model) {
	if (model.$ === 1) {
		var speed = model.a.aa;
		var bottle = model.a.y;
		return elm$core$Platform$Sub$batch(
			_List_fromArray(
				[
					A2(
					elm$core$Platform$Sub$map,
					author$project$OnePlayer$Game$BottleMsg,
					A2(author$project$Bottle$subscriptions, speed, bottle))
				]));
	} else {
		return elm$core$Platform$Sub$none;
	}
};
var author$project$OnePlayer$Menu$Down = 3;
var author$project$OnePlayer$Menu$Enter = 4;
var author$project$OnePlayer$Menu$Left = 1;
var author$project$OnePlayer$Menu$Noop = 5;
var author$project$OnePlayer$Menu$Right = 2;
var author$project$OnePlayer$Menu$Up = 0;
var author$project$OnePlayer$Menu$subscriptions = function (_n0) {
	return elm$browser$Browser$Events$onKeyDown(
		A2(
			elm$json$Json$Decode$map,
			function (key) {
				switch (key) {
					case 13:
						return 4;
					case 38:
						return 0;
					case 37:
						return 1;
					case 39:
						return 2;
					case 40:
						return 3;
					default:
						return 5;
				}
			},
			elm$html$Html$Events$keyCode));
};
var author$project$OnePlayer$subscriptions = function (model) {
	if (!model.$) {
		var state = model.a;
		return A2(
			elm$core$Platform$Sub$map,
			author$project$OnePlayer$MenuMsg,
			author$project$OnePlayer$Menu$subscriptions(state));
	} else {
		var state = model.a;
		return A2(
			elm$core$Platform$Sub$map,
			author$project$OnePlayer$GameMsg,
			author$project$OnePlayer$Game$subscriptions(state));
	}
};
var author$project$TwoPlayer$GameMsg = function (a) {
	return {$: 2, a: a};
};
var author$project$TwoPlayer$MenuMsg = function (a) {
	return {$: 1, a: a};
};
var author$project$TwoPlayer$Game$FirstBottleMsg = function (a) {
	return {$: 0, a: a};
};
var author$project$TwoPlayer$Game$SecondBottleMsg = function (a) {
	return {$: 1, a: a};
};
var author$project$TwoPlayer$Game$subscriptions = function (model) {
	if (model.$ === 2) {
		var first = model.a.g;
		var second = model.a.e;
		return elm$core$Platform$Sub$batch(
			_List_fromArray(
				[
					A2(
					elm$core$Platform$Sub$map,
					author$project$TwoPlayer$Game$FirstBottleMsg,
					A2(author$project$Bottle$subscriptions, first.aa, first.y)),
					A2(
					elm$core$Platform$Sub$map,
					author$project$TwoPlayer$Game$SecondBottleMsg,
					A2(author$project$Bottle$subscriptions, second.aa, second.y))
				]));
	} else {
		return elm$core$Platform$Sub$none;
	}
};
var author$project$TwoPlayer$subscriptions = function (model) {
	if (!model.$) {
		var state = model.a;
		return A2(
			elm$core$Platform$Sub$map,
			author$project$TwoPlayer$MenuMsg,
			author$project$OnePlayer$Menu$subscriptions(state));
	} else {
		var state = model.a;
		return A2(
			elm$core$Platform$Sub$map,
			author$project$TwoPlayer$GameMsg,
			author$project$TwoPlayer$Game$subscriptions(state));
	}
};
var author$project$Main$subscriptions = function (model) {
	switch (model.$) {
		case 1:
			var state = model.a;
			return A2(
				elm$core$Platform$Sub$map,
				author$project$Main$OneMsg,
				author$project$OnePlayer$subscriptions(state));
		case 2:
			var state = model.a;
			return A2(
				elm$core$Platform$Sub$map,
				author$project$Main$TwoMsg,
				author$project$TwoPlayer$subscriptions(state));
		default:
			return elm$core$Platform$Sub$none;
	}
};
var elm$core$Platform$Cmd$map = _Platform_map;
var author$project$Component$mapSimple = F4(
	function (update, toModel, toMsg, result) {
		var _n0 = result;
		var state = _n0.a;
		var cmd = _n0.b;
		return _Utils_Tuple2(
			toModel(state),
			A2(elm$core$Platform$Cmd$map, toMsg, cmd));
	});
var author$project$Main$One = function (a) {
	return {$: 1, a: a};
};
var author$project$Main$Two = function (a) {
	return {$: 2, a: a};
};
var author$project$OnePlayer$Init = function (a) {
	return {$: 0, a: a};
};
var author$project$Bottle$Med = 1;
var author$project$OnePlayer$Menu$Level = 1;
var author$project$OnePlayer$Menu$init = {U: 10, E: 1, aa: 1};
var elm$core$Platform$Cmd$batch = _Platform_batch;
var elm$core$Platform$Cmd$none = elm$core$Platform$Cmd$batch(_List_Nil);
var author$project$OnePlayer$init = _Utils_Tuple2(
	author$project$OnePlayer$Init(author$project$OnePlayer$Menu$init),
	elm$core$Platform$Cmd$none);
var elm$core$Tuple$mapSecond = F2(
	function (func, _n0) {
		var x = _n0.a;
		var y = _n0.b;
		return _Utils_Tuple2(
			x,
			func(y));
	});
var author$project$Component$mapOutMsg = F4(
	function (update, toModel, toMsg, result) {
		if (result.c.$ === 1) {
			var state = result.a;
			var cmd = result.b;
			var _n1 = result.c;
			return _Utils_Tuple2(
				toModel(state),
				A2(elm$core$Platform$Cmd$map, toMsg, cmd));
		} else {
			var newModel = result.a;
			var cmd1 = result.b;
			var msg = result.c.a;
			return A2(
				elm$core$Tuple$mapSecond,
				function (cmd2) {
					return elm$core$Platform$Cmd$batch(
						_List_fromArray(
							[
								A2(elm$core$Platform$Cmd$map, toMsg, cmd1),
								cmd2
							]));
				},
				A2(
					update,
					msg,
					toModel(newModel)));
		}
	});
var author$project$OnePlayer$InGame = function (a) {
	return {$: 1, a: a};
};
var author$project$OnePlayer$Reset = {$: 3};
var author$project$OnePlayer$Start = function (a) {
	return {$: 1, a: a};
};
var author$project$Bottle$Bot = function (a) {
	return {$: 1, a: a};
};
var author$project$Bottle$Falling = function (a) {
	return {$: 1, a: a};
};
var author$project$Bottle$Red = 0;
var author$project$Bottle$Down = 1;
var author$project$Bottle$Horizontal = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var author$project$Bottle$Left = 2;
var author$project$Bottle$Right = 3;
var author$project$Bottle$Up = 0;
var author$project$Bottle$Vertical = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var elm$core$Tuple$pair = F2(
	function (a, b) {
		return _Utils_Tuple2(a, b);
	});
var author$project$Grid$zip = elm$core$List$map2(elm$core$Tuple$pair);
var elm$core$Array$fromListHelp = F3(
	function (list, nodeList, nodeListSize) {
		fromListHelp:
		while (true) {
			var _n0 = A2(elm$core$Elm$JsArray$initializeFromList, elm$core$Array$branchFactor, list);
			var jsArray = _n0.a;
			var remainingItems = _n0.b;
			if (_Utils_cmp(
				elm$core$Elm$JsArray$length(jsArray),
				elm$core$Array$branchFactor) < 0) {
				return A2(
					elm$core$Array$builderToArray,
					true,
					{h: nodeList, c: nodeListSize, f: jsArray});
			} else {
				var $temp$list = remainingItems,
					$temp$nodeList = A2(
					elm$core$List$cons,
					elm$core$Array$Leaf(jsArray),
					nodeList),
					$temp$nodeListSize = nodeListSize + 1;
				list = $temp$list;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue fromListHelp;
			}
		}
	});
var elm$core$Array$fromList = function (list) {
	if (!list.b) {
		return elm$core$Array$empty;
	} else {
		return A3(elm$core$Array$fromListHelp, list, _List_Nil, 0);
	}
};
var elm$core$Bitwise$shiftRightZfBy = _Bitwise_shiftRightZfBy;
var elm$core$Array$bitMask = 4294967295 >>> (32 - elm$core$Array$shiftStep);
var elm$core$Bitwise$and = _Bitwise_and;
var elm$core$Elm$JsArray$unsafeGet = _JsArray_unsafeGet;
var elm$core$Array$getHelp = F3(
	function (shift, index, tree) {
		getHelp:
		while (true) {
			var pos = elm$core$Array$bitMask & (index >>> shift);
			var _n0 = A2(elm$core$Elm$JsArray$unsafeGet, pos, tree);
			if (!_n0.$) {
				var subTree = _n0.a;
				var $temp$shift = shift - elm$core$Array$shiftStep,
					$temp$index = index,
					$temp$tree = subTree;
				shift = $temp$shift;
				index = $temp$index;
				tree = $temp$tree;
				continue getHelp;
			} else {
				var values = _n0.a;
				return A2(elm$core$Elm$JsArray$unsafeGet, elm$core$Array$bitMask & index, values);
			}
		}
	});
var elm$core$Bitwise$shiftLeftBy = _Bitwise_shiftLeftBy;
var elm$core$Array$tailIndex = function (len) {
	return (len >>> 5) << 5;
};
var elm$core$Basics$ge = _Utils_ge;
var elm$core$Array$get = F2(
	function (index, _n0) {
		var len = _n0.a;
		var startShift = _n0.b;
		var tree = _n0.c;
		var tail = _n0.d;
		return ((index < 0) || (_Utils_cmp(index, len) > -1)) ? elm$core$Maybe$Nothing : ((_Utils_cmp(
			index,
			elm$core$Array$tailIndex(len)) > -1) ? elm$core$Maybe$Just(
			A2(elm$core$Elm$JsArray$unsafeGet, elm$core$Array$bitMask & index, tail)) : elm$core$Maybe$Just(
			A3(elm$core$Array$getHelp, startShift, index, tree)));
	});
var elm$core$Basics$negate = function (n) {
	return -n;
};
var elm$core$Basics$neq = _Utils_notEqual;
var elm$core$List$drop = F2(
	function (n, list) {
		drop:
		while (true) {
			if (n <= 0) {
				return list;
			} else {
				if (!list.b) {
					return list;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs;
					n = $temp$n;
					list = $temp$list;
					continue drop;
				}
			}
		}
	});
var elm$core$List$filter = F2(
	function (isGood, list) {
		return A3(
			elm$core$List$foldr,
			F2(
				function (x, xs) {
					return isGood(x) ? A2(elm$core$List$cons, x, xs) : xs;
				}),
			_List_Nil,
			list);
	});
var elm$core$List$head = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return elm$core$Maybe$Just(x);
	} else {
		return elm$core$Maybe$Nothing;
	}
};
var elm$core$List$sortBy = _List_sortBy;
var elm$core$List$takeReverse = F3(
	function (n, list, kept) {
		takeReverse:
		while (true) {
			if (n <= 0) {
				return kept;
			} else {
				if (!list.b) {
					return kept;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs,
						$temp$kept = A2(elm$core$List$cons, x, kept);
					n = $temp$n;
					list = $temp$list;
					kept = $temp$kept;
					continue takeReverse;
				}
			}
		}
	});
var elm$core$List$takeTailRec = F2(
	function (n, list) {
		return elm$core$List$reverse(
			A3(elm$core$List$takeReverse, n, list, _List_Nil));
	});
var elm$core$List$takeFast = F3(
	function (ctr, n, list) {
		if (n <= 0) {
			return _List_Nil;
		} else {
			var _n0 = _Utils_Tuple2(n, list);
			_n0$1:
			while (true) {
				_n0$5:
				while (true) {
					if (!_n0.b.b) {
						return list;
					} else {
						if (_n0.b.b.b) {
							switch (_n0.a) {
								case 1:
									break _n0$1;
								case 2:
									var _n2 = _n0.b;
									var x = _n2.a;
									var _n3 = _n2.b;
									var y = _n3.a;
									return _List_fromArray(
										[x, y]);
								case 3:
									if (_n0.b.b.b.b) {
										var _n4 = _n0.b;
										var x = _n4.a;
										var _n5 = _n4.b;
										var y = _n5.a;
										var _n6 = _n5.b;
										var z = _n6.a;
										return _List_fromArray(
											[x, y, z]);
									} else {
										break _n0$5;
									}
								default:
									if (_n0.b.b.b.b && _n0.b.b.b.b.b) {
										var _n7 = _n0.b;
										var x = _n7.a;
										var _n8 = _n7.b;
										var y = _n8.a;
										var _n9 = _n8.b;
										var z = _n9.a;
										var _n10 = _n9.b;
										var w = _n10.a;
										var tl = _n10.b;
										return (ctr > 1000) ? A2(
											elm$core$List$cons,
											x,
											A2(
												elm$core$List$cons,
												y,
												A2(
													elm$core$List$cons,
													z,
													A2(
														elm$core$List$cons,
														w,
														A2(elm$core$List$takeTailRec, n - 4, tl))))) : A2(
											elm$core$List$cons,
											x,
											A2(
												elm$core$List$cons,
												y,
												A2(
													elm$core$List$cons,
													z,
													A2(
														elm$core$List$cons,
														w,
														A3(elm$core$List$takeFast, ctr + 1, n - 4, tl)))));
									} else {
										break _n0$5;
									}
							}
						} else {
							if (_n0.a === 1) {
								break _n0$1;
							} else {
								break _n0$5;
							}
						}
					}
				}
				return list;
			}
			var _n1 = _n0.b;
			var x = _n1.a;
			return _List_fromArray(
				[x]);
		}
	});
var elm$core$List$take = F2(
	function (n, list) {
		return A3(elm$core$List$takeFast, 0, n, list);
	});
var elm$core$Maybe$andThen = F2(
	function (callback, maybeValue) {
		if (!maybeValue.$) {
			var value = maybeValue.a;
			return callback(value);
		} else {
			return elm$core$Maybe$Nothing;
		}
	});
var elm$core$Maybe$map = F2(
	function (f, maybe) {
		if (!maybe.$) {
			var value = maybe.a;
			return elm$core$Maybe$Just(
				f(value));
		} else {
			return elm$core$Maybe$Nothing;
		}
	});
var elm$core$Maybe$withDefault = F2(
	function (_default, maybe) {
		if (!maybe.$) {
			var value = maybe.a;
			return value;
		} else {
			return _default;
		}
	});
var elm$core$Tuple$second = function (_n0) {
	var y = _n0.b;
	return y;
};
var elm_community$list_extra$List$Extra$maximumBy = F2(
	function (f, ls) {
		var maxBy = F2(
			function (x, _n1) {
				var y = _n1.a;
				var fy = _n1.b;
				var fx = f(x);
				return (_Utils_cmp(fx, fy) > 0) ? _Utils_Tuple2(x, fx) : _Utils_Tuple2(y, fy);
			});
		if (ls.b) {
			if (!ls.b.b) {
				var l_ = ls.a;
				return elm$core$Maybe$Just(l_);
			} else {
				var l_ = ls.a;
				var ls_ = ls.b;
				return elm$core$Maybe$Just(
					A3(
						elm$core$List$foldl,
						maxBy,
						_Utils_Tuple2(
							l_,
							f(l_)),
						ls_).a);
			}
		} else {
			return elm$core$Maybe$Nothing;
		}
	});
var elm_community$list_extra$List$Extra$minimumBy = F2(
	function (f, ls) {
		var minBy = F2(
			function (x, _n1) {
				var y = _n1.a;
				var fy = _n1.b;
				var fx = f(x);
				return (_Utils_cmp(fx, fy) < 0) ? _Utils_Tuple2(x, fx) : _Utils_Tuple2(y, fy);
			});
		if (ls.b) {
			if (!ls.b.b) {
				var l_ = ls.a;
				return elm$core$Maybe$Just(l_);
			} else {
				var l_ = ls.a;
				var ls_ = ls.b;
				return elm$core$Maybe$Just(
					A3(
						elm$core$List$foldl,
						minBy,
						_Utils_Tuple2(
							l_,
							f(l_)),
						ls_).a);
			}
		} else {
			return elm$core$Maybe$Nothing;
		}
	});
var elm_community$list_extra$List$Extra$takeWhile = function (predicate) {
	var takeWhileMemo = F2(
		function (memo, list) {
			takeWhileMemo:
			while (true) {
				if (!list.b) {
					return elm$core$List$reverse(memo);
				} else {
					var x = list.a;
					var xs = list.b;
					if (predicate(x)) {
						var $temp$memo = A2(elm$core$List$cons, x, memo),
							$temp$list = xs;
						memo = $temp$memo;
						list = $temp$list;
						continue takeWhileMemo;
					} else {
						return elm$core$List$reverse(memo);
					}
				}
			}
		});
	return takeWhileMemo(_List_Nil);
};
var author$project$Bottle$trashBot = F2(
	function (bottle, mode) {
		switch (mode.$) {
			case 1:
				return _Utils_Tuple2(elm$core$Maybe$Nothing, elm$core$Maybe$Nothing);
			case 2:
				return _Utils_Tuple2(elm$core$Maybe$Nothing, elm$core$Maybe$Nothing);
			default:
				var pill = mode.a;
				var coords = mode.b;
				var peaks = A2(
					elm$core$List$filterMap,
					elm$core$Basics$identity,
					A2(
						elm$core$List$map,
						function (column) {
							return elm$core$List$head(
								A2(
									elm$core$List$filter,
									function (cell) {
										var _n13 = cell.b;
										if (!_n13.$) {
											return _Utils_cmp(cell.d.b, coords.b) > -1;
										} else {
											return false;
										}
									},
									column));
						},
						bottle));
				var orientationBonus = function (o) {
					if (_Utils_eq(o, pill)) {
						return 2;
					} else {
						if (!pill.$) {
							return 0;
						} else {
							var a = pill.a;
							var b = pill.b;
							return _Utils_eq(a, b) ? 1 : 0;
						}
					}
				};
				var colorIndexScore = F2(
					function (color, index) {
						var scoring = {ag: 0, al: 50, ao: 120};
						var colorAtIndex = A2(
							elm$core$Maybe$map,
							function (state) {
								return state.a;
							},
							A2(
								elm$core$Maybe$andThen,
								function (cell) {
									return cell.b;
								},
								A2(
									elm$core$Array$get,
									index - 1,
									elm$core$Array$fromList(peaks))));
						if (colorAtIndex.$ === 1) {
							return scoring.al;
						} else {
							var aColor = colorAtIndex.a;
							return _Utils_eq(aColor, color) ? scoring.ao : scoring.ag;
						}
					});
				var _n1 = function () {
					if (pill.$ === 1) {
						var a = pill.a;
						var b = pill.b;
						return _Utils_Tuple2(a, b);
					} else {
						var a = pill.a;
						var b = pill.b;
						return _Utils_Tuple2(a, b);
					}
				}();
				var color_a = _n1.a;
				var color_b = _n1.b;
				var options = function () {
					var heads = A2(
						elm$core$List$map,
						function (column) {
							return A2(
								elm$core$Maybe$withDefault,
								{
									d: _Utils_Tuple2(-1, -1),
									b: elm$core$Maybe$Nothing
								},
								elm$core$List$head(column));
						},
						A2(
							elm$core$List$map,
							function (column) {
								return A2(elm$core$List$drop, coords.b - 1, column);
							},
							bottle));
					var getOpenings = elm_community$list_extra$List$Extra$takeWhile(
						function (cell) {
							return _Utils_eq(cell.b, elm$core$Maybe$Nothing);
						});
					var _n9 = _Utils_Tuple2(
						getOpenings(
							elm$core$List$reverse(
								A2(elm$core$List$take, coords.a, heads))),
						getOpenings(
							A2(elm$core$List$drop, coords.a, heads)));
					var before = _n9.a;
					var after = _n9.b;
					var openCells = _Utils_ap(before, after);
					var _n10 = _Utils_Tuple2(
						A2(
							elm$core$Maybe$withDefault,
							coords.a,
							A2(
								elm$core$Maybe$map,
								A2(
									elm$core$Basics$composeR,
									function ($) {
										return $.d;
									},
									elm$core$Tuple$first),
								A2(
									elm_community$list_extra$List$Extra$minimumBy,
									function (cell) {
										return cell.d.a;
									},
									openCells))),
						A2(
							elm$core$Maybe$withDefault,
							coords.a,
							A2(
								elm$core$Maybe$map,
								A2(
									elm$core$Basics$composeR,
									function ($) {
										return $.d;
									},
									elm$core$Tuple$first),
								A2(
									elm_community$list_extra$List$Extra$maximumBy,
									function (cell) {
										return cell.d.a;
									},
									openCells))));
					var minX = _n10.a;
					var maxX = _n10.b;
					return _Utils_ap(
						A2(
							elm$core$List$map,
							function (x) {
								return _Utils_Tuple2(
									x,
									A2(author$project$Bottle$Vertical, color_a, color_b));
							},
							A2(elm$core$List$range, minX, maxX)),
						_Utils_ap(
							_Utils_eq(color_a, color_b) ? _List_Nil : A2(
								elm$core$List$map,
								function (x) {
									return _Utils_Tuple2(
										x,
										A2(author$project$Bottle$Horizontal, color_b, color_a));
								},
								A2(elm$core$List$range, minX, maxX - 1)),
							A2(
								elm$core$List$map,
								function (x) {
									return _Utils_Tuple2(
										x,
										A2(author$project$Bottle$Horizontal, color_a, color_b));
								},
								A2(elm$core$List$range, minX, maxX - 1))));
				}();
				var scores = A2(
					elm$core$List$map,
					function (_n7) {
						var x = _n7.a;
						var orientation = _n7.b;
						return orientationBonus(orientation) + function () {
							if (!orientation.$) {
								var a = orientation.a;
								var b = orientation.b;
								return A2(colorIndexScore, a, x) + A2(colorIndexScore, b, x + 1);
							} else {
								var a = orientation.a;
								var b = orientation.b;
								return _Utils_eq(a, b) ? (A2(colorIndexScore, a, x) + A2(colorIndexScore, b, x)) : A2(colorIndexScore, b, x);
							}
						}();
					},
					options);
				var choice = elm$core$List$head(
					A2(
						elm$core$List$map,
						elm$core$Tuple$second,
						A2(
							elm$core$List$sortBy,
							A2(
								elm$core$Basics$composeR,
								elm$core$Tuple$first,
								function (a) {
									return -a;
								}),
							A2(author$project$Grid$zip, scores, options))));
				var withGoal = function (dir) {
					return _Utils_Tuple2(dir, choice);
				};
				var _n3 = _Utils_Tuple2(choice, coords);
				if (!_n3.a.$) {
					var _n4 = _n3.a.a;
					var aimX = _n4.a;
					var pill_ = _n4.b;
					var _n5 = _n3.b;
					var x = _n5.a;
					return (!_Utils_eq(pill_, pill)) ? withGoal(
						elm$core$Maybe$Just(0)) : ((_Utils_cmp(aimX, x) > 0) ? withGoal(
						elm$core$Maybe$Just(3)) : ((_Utils_cmp(aimX, x) < 0) ? withGoal(
						elm$core$Maybe$Just(2)) : withGoal(
						elm$core$Maybe$Just(1))));
				} else {
					var _n6 = _n3.a;
					return withGoal(elm$core$Maybe$Nothing);
				}
		}
	});
var author$project$Grid$Cell = F2(
	function (coords, state) {
		return {d: coords, b: state};
	});
var author$project$Grid$fromDimensions = F2(
	function (width_, height_) {
		var makeColumn = function (x) {
			return A2(
				elm$core$List$map,
				function (y) {
					return A2(
						author$project$Grid$Cell,
						_Utils_Tuple2(x, y),
						elm$core$Maybe$Nothing);
				},
				A2(elm$core$List$range, 1, height_));
		};
		return A2(
			elm$core$List$map,
			makeColumn,
			A2(elm$core$List$range, 1, width_));
	});
var author$project$Bottle$init = {
	n: _List_Nil,
	a: A2(author$project$Grid$fromDimensions, 8, 16),
	R: author$project$Bottle$Bot(author$project$Bottle$trashBot),
	T: elm$core$Maybe$Nothing,
	i: author$project$Bottle$Falling(_List_Nil),
	L: _Utils_Tuple2(0, 0)
};
var author$project$Bottle$Blue = 1;
var author$project$Bottle$Yellow = 2;
var elm$random$Random$Generator = elm$core$Basics$identity;
var elm$random$Random$Seed = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var elm$random$Random$next = function (_n0) {
	var state0 = _n0.a;
	var incr = _n0.b;
	return A2(elm$random$Random$Seed, ((state0 * 1664525) + incr) >>> 0, incr);
};
var elm$core$Bitwise$xor = _Bitwise_xor;
var elm$random$Random$peel = function (_n0) {
	var state = _n0.a;
	var word = (state ^ (state >>> ((state >>> 28) + 4))) * 277803737;
	return ((word >>> 22) ^ word) >>> 0;
};
var elm$random$Random$int = F2(
	function (a, b) {
		return function (seed0) {
			var _n0 = (_Utils_cmp(a, b) < 0) ? _Utils_Tuple2(a, b) : _Utils_Tuple2(b, a);
			var lo = _n0.a;
			var hi = _n0.b;
			var range = (hi - lo) + 1;
			if (!((range - 1) & range)) {
				return _Utils_Tuple2(
					(((range - 1) & elm$random$Random$peel(seed0)) >>> 0) + lo,
					elm$random$Random$next(seed0));
			} else {
				var threshhold = (((-range) >>> 0) % range) >>> 0;
				var accountForBias = function (seed) {
					accountForBias:
					while (true) {
						var x = elm$random$Random$peel(seed);
						var seedN = elm$random$Random$next(seed);
						if (_Utils_cmp(x, threshhold) < 0) {
							var $temp$seed = seedN;
							seed = $temp$seed;
							continue accountForBias;
						} else {
							return _Utils_Tuple2((x % range) + lo, seedN);
						}
					}
				};
				return accountForBias(seed0);
			}
		};
	});
var elm$random$Random$map = F2(
	function (func, _n0) {
		var genA = _n0;
		return function (seed0) {
			var _n1 = genA(seed0);
			var a = _n1.a;
			var seed1 = _n1.b;
			return _Utils_Tuple2(
				func(a),
				seed1);
		};
	});
var author$project$RandomExtra$selectWithDefault = F2(
	function (defaultValue, options) {
		var get = F2(
			function (index, list) {
				if (index < 0) {
					return elm$core$Maybe$Nothing;
				} else {
					var _n0 = A2(elm$core$List$drop, index, list);
					if (!_n0.b) {
						return elm$core$Maybe$Nothing;
					} else {
						var x = _n0.a;
						var xs = _n0.b;
						return elm$core$Maybe$Just(x);
					}
				}
			});
		var select = function (list) {
			return A2(
				elm$random$Random$map,
				function (index) {
					return A2(get, index, list);
				},
				A2(
					elm$random$Random$int,
					0,
					elm$core$List$length(list) - 1));
		};
		return A2(
			elm$random$Random$map,
			elm$core$Maybe$withDefault(defaultValue),
			select(options));
	});
var author$project$Bottle$generateColor = A2(
	author$project$RandomExtra$selectWithDefault,
	1,
	_List_fromArray(
		[0, 2, 1]));
var elm$core$List$append = F2(
	function (xs, ys) {
		if (!ys.b) {
			return xs;
		} else {
			return A3(elm$core$List$foldr, elm$core$List$cons, ys, xs);
		}
	});
var elm$core$List$concat = function (lists) {
	return A3(elm$core$List$foldr, elm$core$List$append, _List_Nil, lists);
};
var author$project$Grid$toList = function (grid) {
	return elm$core$List$concat(grid);
};
var author$project$Grid$filter = F2(
	function (predicate, grid) {
		return A2(
			elm$core$List$filter,
			predicate,
			author$project$Grid$toList(grid));
	});
var author$project$Grid$find = F2(
	function (test, list) {
		return elm$core$List$head(
			A2(elm$core$List$filter, test, list));
	});
var author$project$Grid$findCellAtCoords = F2(
	function (coords, grid) {
		return A2(
			elm$core$Maybe$withDefault,
			A2(
				author$project$Grid$Cell,
				_Utils_Tuple2(-1, -1),
				elm$core$Maybe$Nothing),
			A2(
				author$project$Grid$find,
				function (cell) {
					return _Utils_eq(cell.d, coords);
				},
				author$project$Grid$toList(grid)));
	});
var author$project$Grid$isEmpty = F2(
	function (coords, grid) {
		return A3(
			elm$core$Basics$composeR,
			function ($) {
				return $.b;
			},
			elm$core$Basics$eq(elm$core$Maybe$Nothing),
			A2(author$project$Grid$findCellAtCoords, coords, grid));
	});
var author$project$Bottle$generateEmptyCoords = function (grid) {
	var emptyCoords = A2(
		elm$core$List$map,
		function ($) {
			return $.d;
		},
		A2(
			author$project$Grid$filter,
			function (_n0) {
				var coords = _n0.d;
				return (coords.b >= 5) && A2(author$project$Grid$isEmpty, coords, grid);
			},
			grid));
	return A2(
		author$project$RandomExtra$selectWithDefault,
		_Utils_Tuple2(-1, -1),
		emptyCoords);
};
var author$project$LevelCreator$NewVirus = function (a) {
	return {$: 0, a: a};
};
var elm$random$Random$Generate = elm$core$Basics$identity;
var elm$random$Random$initialSeed = function (x) {
	var _n0 = elm$random$Random$next(
		A2(elm$random$Random$Seed, 0, 1013904223));
	var state1 = _n0.a;
	var incr = _n0.b;
	var state2 = (state1 + x) >>> 0;
	return elm$random$Random$next(
		A2(elm$random$Random$Seed, state2, incr));
};
var elm$time$Time$posixToMillis = function (_n0) {
	var millis = _n0;
	return millis;
};
var elm$random$Random$init = A2(
	elm$core$Task$andThen,
	function (time) {
		return elm$core$Task$succeed(
			elm$random$Random$initialSeed(
				elm$time$Time$posixToMillis(time)));
	},
	elm$time$Time$now);
var elm$random$Random$step = F2(
	function (_n0, seed) {
		var generator = _n0;
		return generator(seed);
	});
var elm$random$Random$onEffects = F3(
	function (router, commands, seed) {
		if (!commands.b) {
			return elm$core$Task$succeed(seed);
		} else {
			var generator = commands.a;
			var rest = commands.b;
			var _n1 = A2(elm$random$Random$step, generator, seed);
			var value = _n1.a;
			var newSeed = _n1.b;
			return A2(
				elm$core$Task$andThen,
				function (_n2) {
					return A3(elm$random$Random$onEffects, router, rest, newSeed);
				},
				A2(elm$core$Platform$sendToApp, router, value));
		}
	});
var elm$random$Random$onSelfMsg = F3(
	function (_n0, _n1, seed) {
		return elm$core$Task$succeed(seed);
	});
var elm$random$Random$cmdMap = F2(
	function (func, _n0) {
		var generator = _n0;
		return A2(elm$random$Random$map, func, generator);
	});
_Platform_effectManagers['Random'] = _Platform_createManager(elm$random$Random$init, elm$random$Random$onEffects, elm$random$Random$onSelfMsg, elm$random$Random$cmdMap);
var elm$random$Random$command = _Platform_leaf('Random');
var elm$random$Random$generate = F2(
	function (tagger, generator) {
		return elm$random$Random$command(
			A2(elm$random$Random$map, tagger, generator));
	});
var elm$random$Random$map2 = F3(
	function (func, _n0, _n1) {
		var genA = _n0;
		var genB = _n1;
		return function (seed0) {
			var _n2 = genA(seed0);
			var a = _n2.a;
			var seed1 = _n2.b;
			var _n3 = genB(seed1);
			var b = _n3.a;
			var seed2 = _n3.b;
			return _Utils_Tuple2(
				A2(func, a, b),
				seed2);
		};
	});
var elm$random$Random$pair = F2(
	function (genA, genB) {
		return A3(
			elm$random$Random$map2,
			F2(
				function (a, b) {
					return _Utils_Tuple2(a, b);
				}),
			genA,
			genB);
	});
var author$project$LevelCreator$randomNewVirus = function (bottle) {
	return A2(
		elm$random$Random$generate,
		author$project$LevelCreator$NewVirus,
		A2(
			elm$random$Random$pair,
			author$project$Bottle$generateColor,
			author$project$Bottle$generateEmptyCoords(bottle)));
};
var author$project$LevelCreator$init = function (level) {
	var bottle = author$project$Bottle$init;
	return _Utils_Tuple2(
		{y: bottle, U: level},
		author$project$LevelCreator$randomNewVirus(bottle.a));
};
var author$project$OnePlayer$Game$CreatorMsg = function (a) {
	return {$: 1, a: a};
};
var author$project$OnePlayer$Game$PrepareGame = function (a) {
	return {$: 0, a: a};
};
var author$project$OnePlayer$Game$initWithScore = F3(
	function (level, speed, score) {
		var _n0 = author$project$LevelCreator$init(level);
		var creator = _n0.a;
		var cmd = _n0.b;
		return _Utils_Tuple2(
			author$project$OnePlayer$Game$PrepareGame(
				{S: creator, m: score, aa: speed}),
			A2(elm$core$Platform$Cmd$map, author$project$OnePlayer$Game$CreatorMsg, cmd));
	});
var author$project$OnePlayer$Game$init = F2(
	function (level, speed) {
		return A3(author$project$OnePlayer$Game$initWithScore, level, speed, 0);
	});
var author$project$Bottle$pillCoordsPair = F2(
	function (pill, _n0) {
		var x = _n0.a;
		var y = _n0.b;
		if (!pill.$) {
			return _List_fromArray(
				[
					_Utils_Tuple2(x, y + 1),
					_Utils_Tuple2(x + 1, y + 1)
				]);
		} else {
			return _List_fromArray(
				[
					_Utils_Tuple2(x, y),
					_Utils_Tuple2(x, y + 1)
				]);
		}
	});
var elm$core$Basics$not = _Basics_not;
var elm$core$List$any = F2(
	function (isOkay, list) {
		any:
		while (true) {
			if (!list.b) {
				return false;
			} else {
				var x = list.a;
				var xs = list.b;
				if (isOkay(x)) {
					return true;
				} else {
					var $temp$isOkay = isOkay,
						$temp$list = xs;
					isOkay = $temp$isOkay;
					list = $temp$list;
					continue any;
				}
			}
		}
	});
var author$project$Bottle$hasConflict = function (_n0) {
	var mode = _n0.i;
	var contents = _n0.a;
	if (!mode.$) {
		var pill = mode.a;
		var coords = mode.b;
		return A2(
			elm$core$List$any,
			elm$core$Basics$not,
			A2(
				elm$core$List$map,
				function (p) {
					return A2(author$project$Grid$isEmpty, p, contents);
				},
				A2(author$project$Bottle$pillCoordsPair, pill, coords)));
	} else {
		return false;
	}
};
var author$project$Bottle$totalViruses = function (contents) {
	return elm$core$List$length(
		A2(
			author$project$Grid$filter,
			function (c) {
				var _n0 = c.b;
				if ((!_n0.$) && (!_n0.a.b.$)) {
					var _n1 = _n0.a;
					var _n2 = _n1.b;
					return true;
				} else {
					return false;
				}
			},
			contents));
};
var author$project$Bottle$Bomb = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var author$project$Bottle$Pill = function (a) {
	return {$: 1, a: a};
};
var author$project$Bottle$PlacingPill = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var author$project$Bottle$Bombing = {$: 2};
var author$project$Bottle$NewPill = function (a) {
	return {$: 0, a: a};
};
var author$project$Bottle$colorCoords = F2(
	function (pill, coords) {
		var _n0 = function () {
			if (!pill.$) {
				var a = pill.a;
				var b = pill.b;
				return _Utils_Tuple2(
					_Utils_Tuple2(a, 3),
					_Utils_Tuple2(b, 2));
			} else {
				var a = pill.a;
				var b = pill.b;
				return _Utils_Tuple2(
					_Utils_Tuple2(a, 1),
					_Utils_Tuple2(b, 0));
			}
		}();
		var _n1 = _n0.a;
		var a_color = _n1.a;
		var a_dep = _n1.b;
		var _n2 = _n0.b;
		var b_color = _n2.a;
		var b_dep = _n2.b;
		var _n4 = A2(author$project$Bottle$pillCoordsPair, pill, coords);
		if ((_n4.b && _n4.b.b) && (!_n4.b.b.b)) {
			var first = _n4.a;
			var _n5 = _n4.b;
			var second = _n5.a;
			return _List_fromArray(
				[
					_Utils_Tuple3(first, a_color, a_dep),
					_Utils_Tuple3(second, b_color, b_dep)
				]);
		} else {
			return _List_Nil;
		}
	});
var author$project$Grid$map = F2(
	function (f, grid) {
		return A2(
			elm$core$List$map,
			elm$core$List$map(f),
			grid);
	});
var author$project$Grid$updateCellAtCoords = F3(
	function (update, coords, grid) {
		return A2(
			author$project$Grid$map,
			function (cell) {
				return _Utils_eq(cell.d, coords) ? update(cell) : cell;
			},
			grid);
	});
var author$project$Grid$setState = F3(
	function (state, coords, grid) {
		return A3(
			author$project$Grid$updateCellAtCoords,
			function (c) {
				return _Utils_update(
					c,
					{
						b: elm$core$Maybe$Just(state)
					});
			},
			coords,
			grid);
	});
var author$project$Bottle$addPill = F3(
	function (pill, coords, bottle) {
		return A3(
			elm$core$List$foldl,
			F2(
				function (_n0, grid) {
					var coords_ = _n0.a;
					var color = _n0.b;
					var dependent = _n0.c;
					return A3(
						author$project$Grid$setState,
						_Utils_Tuple2(
							color,
							author$project$Bottle$Pill(
								elm$core$Maybe$Just(dependent))),
						coords_,
						grid);
				}),
			bottle,
			A2(author$project$Bottle$colorCoords, pill, coords));
	});
var author$project$Bottle$coordsWithDirection = F2(
	function (_n0, direction) {
		var x = _n0.a;
		var y = _n0.b;
		switch (direction) {
			case 0:
				return _Utils_Tuple2(x, y - 1);
			case 1:
				return _Utils_Tuple2(x, y + 1);
			case 2:
				return _Utils_Tuple2(x - 1, y);
			default:
				return _Utils_Tuple2(x + 1, y);
		}
	});
var author$project$Grid$below = F2(
	function (_n0, grid) {
		var x = _n0.a;
		var y = _n0.b;
		var _n1 = elm$core$List$head(
			A2(elm$core$List$drop, x - 1, grid));
		if (_n1.$ === 1) {
			return _List_Nil;
		} else {
			var column = _n1.a;
			return A2(elm$core$List$drop, y, column);
		}
	});
var author$project$Bottle$canFall = F2(
	function (coords, bottle) {
		canFall:
		while (true) {
			var hasRoom = function (cells) {
				hasRoom:
				while (true) {
					if (!cells.b) {
						return false;
					} else {
						var head = cells.a;
						var tail = cells.b;
						var _n1 = head.b;
						if (_n1.$ === 1) {
							return true;
						} else {
							if (_n1.a.b.$ === 1) {
								if (_n1.a.b.a.$ === 1) {
									var _n2 = _n1.a;
									var _n3 = _n2.b.a;
									var $temp$cells = tail;
									cells = $temp$cells;
									continue hasRoom;
								} else {
									var _n4 = _n1.a;
									var dependent = _n4.b.a;
									return A2(author$project$Bottle$canFall, head.d, bottle);
								}
							} else {
								var _n5 = _n1.a;
								var _n6 = _n5.b;
								return false;
							}
						}
					}
				}
			};
			var cell = A2(author$project$Grid$findCellAtCoords, coords, bottle);
			var _n7 = cell.b;
			if ((!_n7.$) && (_n7.a.b.$ === 1)) {
				if (_n7.a.b.a.$ === 1) {
					var _n8 = _n7.a;
					var _n9 = _n8.b.a;
					return hasRoom(
						A2(author$project$Grid$below, coords, bottle));
				} else {
					switch (_n7.a.b.a.a) {
						case 0:
							var _n10 = _n7.a;
							var _n11 = _n10.b.a.a;
							return hasRoom(
								A2(author$project$Grid$below, coords, bottle));
						case 1:
							var _n12 = _n7.a;
							var _n13 = _n12.b.a.a;
							var $temp$coords = A2(author$project$Bottle$coordsWithDirection, coords, 1),
								$temp$bottle = bottle;
							coords = $temp$coords;
							bottle = $temp$bottle;
							continue canFall;
						default:
							var _n14 = _n7.a;
							var dependent = _n14.b.a.a;
							return hasRoom(
								A2(author$project$Grid$below, coords, bottle)) && hasRoom(
								A2(
									author$project$Grid$below,
									A2(author$project$Bottle$coordsWithDirection, coords, dependent),
									bottle));
					}
				}
			} else {
				return false;
			}
		}
	});
var author$project$Bottle$subLists = F2(
	function (len, list) {
		return (_Utils_cmp(
			elm$core$List$length(list),
			len) < 0) ? _List_Nil : A2(
			elm$core$List$cons,
			A2(elm$core$List$take, len, list),
			A2(
				author$project$Bottle$subLists,
				len,
				A2(elm$core$List$drop, 1, list)));
	});
var elm$core$List$all = F2(
	function (isOkay, list) {
		return !A2(
			elm$core$List$any,
			A2(elm$core$Basics$composeL, elm$core$Basics$not, isOkay),
			list);
	});
var author$project$Bottle$isCleared = F2(
	function (_n0, grid) {
		var x = _n0.a;
		var y = _n0.b;
		var len = 4;
		var neighbors = function (f) {
			return A2(
				author$project$Bottle$subLists,
				len,
				A2(
					elm$core$List$map,
					function (coords) {
						return A2(author$project$Grid$findCellAtCoords, coords, grid);
					},
					A2(
						elm$core$List$map,
						f,
						A2(elm$core$List$range, (len * (-1)) + 1, len - 1))));
		};
		var vertical = neighbors(
			function (offset) {
				return _Utils_Tuple2(x, y + offset);
			});
		var horizontal = neighbors(
			function (offset) {
				return _Utils_Tuple2(x + offset, y);
			});
		var cell = A2(
			author$project$Grid$findCellAtCoords,
			_Utils_Tuple2(x, y),
			grid);
		var _n1 = cell.b;
		if (_n1.$ === 1) {
			return false;
		} else {
			var _n2 = _n1.a;
			var color = _n2.a;
			return A2(
				elm$core$List$any,
				elm$core$List$all(
					function (cell_) {
						var _n3 = cell_.b;
						if (!_n3.$) {
							var _n4 = _n3.a;
							var c = _n4.a;
							return _Utils_eq(c, color);
						} else {
							return false;
						}
					}),
				_Utils_ap(vertical, horizontal));
		}
	});
var author$project$Bottle$canSweep = function (grid) {
	return A3(
		elm$core$Basics$composeR,
		elm$core$List$length,
		elm$core$Basics$neq(0),
		A2(
			author$project$Grid$filter,
			function (cell) {
				return A2(author$project$Bottle$isCleared, cell.d, grid);
			},
			grid));
};
var author$project$Bottle$fall = function (bottle) {
	return A2(
		author$project$Grid$map,
		function (cell) {
			var coords = cell.d;
			var state = cell.b;
			var _n0 = coords;
			var x = _n0.a;
			var y = _n0.b;
			return A2(
				author$project$Bottle$canFall,
				_Utils_Tuple2(x, y),
				bottle) ? (A2(
				author$project$Bottle$canFall,
				_Utils_Tuple2(x, y - 1),
				bottle) ? _Utils_update(
				cell,
				{
					b: A2(
						author$project$Grid$findCellAtCoords,
						_Utils_Tuple2(x, y - 1),
						bottle).b
				}) : _Utils_update(
				cell,
				{b: elm$core$Maybe$Nothing})) : ((_Utils_eq(state, elm$core$Maybe$Nothing) && A2(
				author$project$Bottle$canFall,
				_Utils_Tuple2(x, y - 1),
				bottle)) ? _Utils_update(
				cell,
				{
					b: A2(
						author$project$Grid$findCellAtCoords,
						_Utils_Tuple2(x, y - 1),
						bottle).b
				}) : cell);
		},
		bottle);
};
var author$project$Grid$topRow = function (grid) {
	var go = F2(
		function (result, grid_) {
			go:
			while (true) {
				if (grid_.b) {
					var head = grid_.a;
					var tail = grid_.b;
					if (!head.$) {
						var cell = head.a;
						var $temp$result = A2(elm$core$List$cons, cell, result),
							$temp$grid_ = tail;
						result = $temp$result;
						grid_ = $temp$grid_;
						continue go;
					} else {
						var $temp$result = result,
							$temp$grid_ = tail;
						result = $temp$result;
						grid_ = $temp$grid_;
						continue go;
					}
				} else {
					return result;
				}
			}
		});
	return A2(
		go,
		_List_Nil,
		A2(elm$core$List$map, elm$core$List$head, grid));
};
var author$project$Bottle$generateBomb = function (bottle) {
	return A2(
		author$project$RandomExtra$selectWithDefault,
		-1,
		A2(
			elm$core$List$map,
			A2(
				elm$core$Basics$composeR,
				function ($) {
					return $.d;
				},
				elm$core$Tuple$first),
			A2(
				elm$core$List$filter,
				function (c) {
					var _n0 = c.b;
					if (!_n0.$) {
						return false;
					} else {
						return true;
					}
				},
				author$project$Grid$topRow(bottle))));
};
var author$project$Bottle$generatePill = A2(elm$random$Random$pair, author$project$Bottle$generateColor, author$project$Bottle$generateColor);
var author$project$Grid$height = function (grid) {
	if (!grid.b) {
		return 0;
	} else {
		var head = grid.a;
		return elm$core$List$length(head);
	}
};
var author$project$Grid$width = function (grid) {
	return elm$core$List$length(grid);
};
var author$project$Bottle$isAvailable = F3(
	function (coords, pill, grid) {
		var x = coords.a;
		var y = coords.b;
		var withinRight = function () {
			if (pill.$ === 1) {
				return _Utils_cmp(
					x,
					author$project$Grid$width(grid)) < 1;
			} else {
				return _Utils_cmp(
					x,
					author$project$Grid$width(grid)) < 0;
			}
		}();
		var noOccupant = A2(
			elm$core$List$all,
			elm$core$Basics$identity,
			A2(
				elm$core$List$map,
				function (p) {
					return A2(author$project$Grid$isEmpty, p, grid);
				},
				A2(author$project$Bottle$pillCoordsPair, pill, coords)));
		var aboveBottom = _Utils_cmp(
			y,
			author$project$Grid$height(grid)) < 0;
		var inBottle = (x >= 1) && (withinRight && aboveBottom);
		return inBottle && noOccupant;
	});
var author$project$Grid$difference = F3(
	function (diff, a, b) {
		return A2(
			elm$core$List$filterMap,
			function (_n0) {
				var y = _n0.a;
				var z = _n0.b;
				return A2(diff, y.b, z.b) ? elm$core$Maybe$Just(y) : elm$core$Maybe$Nothing;
			},
			A2(
				author$project$Grid$zip,
				author$project$Grid$toList(a),
				author$project$Grid$toList(b)));
	});
var elm$core$Set$Set_elm_builtin = elm$core$Basics$identity;
var elm$core$Set$empty = elm$core$Dict$empty;
var elm$core$Set$insert = F2(
	function (key, _n0) {
		var dict = _n0;
		return A3(elm$core$Dict$insert, key, 0, dict);
	});
var elm$core$Set$fromList = function (list) {
	return A3(elm$core$List$foldl, elm$core$Set$insert, elm$core$Set$empty, list);
};
var elm$core$Dict$member = F2(
	function (key, dict) {
		var _n0 = A2(elm$core$Dict$get, key, dict);
		if (!_n0.$) {
			return true;
		} else {
			return false;
		}
	});
var elm$core$Set$member = F2(
	function (key, _n0) {
		var dict = _n0;
		return A2(elm$core$Dict$member, key, dict);
	});
var author$project$Bottle$sweep = function (model) {
	var contents = model.a;
	var coordsLosingDependent = elm$core$Set$fromList(
		A2(
			elm$core$List$map,
			function (_n13) {
				var coords = _n13.d;
				var state = _n13.b;
				if (((!state.$) && (state.a.b.$ === 1)) && (!state.a.b.a.$)) {
					var _n15 = state.a;
					var dependent = _n15.b.a.a;
					return A2(author$project$Bottle$coordsWithDirection, coords, dependent);
				} else {
					return _Utils_Tuple2(-1, -1);
				}
			},
			A2(
				author$project$Grid$filter,
				function (cell) {
					var coords = cell.d;
					var state = cell.b;
					if (((!state.$) && (state.a.b.$ === 1)) && (!state.a.b.a.$)) {
						var _n12 = state.a;
						var dependent = _n12.b.a.a;
						return A2(author$project$Bottle$isCleared, coords, contents) ? true : false;
					} else {
						return false;
					}
				},
				contents)));
	var swept = A2(
		author$project$Grid$map,
		function (cell) {
			var coords = cell.d;
			var state = cell.b;
			if (A2(author$project$Bottle$isCleared, coords, contents)) {
				return _Utils_update(
					cell,
					{b: elm$core$Maybe$Nothing});
			} else {
				if (A2(elm$core$Set$member, coords, coordsLosingDependent)) {
					if (!state.$) {
						var _n10 = state.a;
						var color = _n10.a;
						return _Utils_update(
							cell,
							{
								b: elm$core$Maybe$Just(
									_Utils_Tuple2(
										color,
										author$project$Bottle$Pill(elm$core$Maybe$Nothing)))
							});
					} else {
						return cell;
					}
				} else {
					return cell;
				}
			}
		},
		contents);
	var diff = A3(
		author$project$Grid$difference,
		F2(
			function (a, b) {
				var _n7 = _Utils_Tuple2(a, b);
				if ((!_n7.a.$) && (_n7.b.$ === 1)) {
					var _n8 = _n7.b;
					return true;
				} else {
					return false;
				}
			}),
		contents,
		swept);
	var clearedLines = function (cells) {
		if (!cells.b) {
			return _List_Nil;
		} else {
			var x = cells.a;
			var xs = cells.b;
			var _n1 = x.b;
			if (!_n1.$) {
				var _n2 = _n1.a;
				var color = _n2.a;
				return A2(
					elm$core$List$cons,
					color,
					clearedLines(
						A2(
							elm$core$List$filter,
							function (c) {
								var _n3 = _Utils_Tuple2(x.d, c.d);
								var _n4 = _n3.a;
								var xx = _n4.a;
								var xy = _n4.b;
								var _n5 = _n3.b;
								var cx = _n5.a;
								var cy = _n5.b;
								return (!_Utils_eq(cx, xx)) && (!_Utils_eq(cy, xy));
							},
							xs)));
			} else {
				return _List_Nil;
			}
		}
	};
	var alreadyCleared = function () {
		var _n6 = model.i;
		if (_n6.$ === 1) {
			var cleared = _n6.a;
			return cleared;
		} else {
			return _List_Nil;
		}
	}();
	return _Utils_update(
		model,
		{
			a: swept,
			i: author$project$Bottle$Falling(
				_Utils_ap(
					alreadyCleared,
					clearedLines(diff)))
		});
};
var author$project$Bottle$withNothing = function (model) {
	return _Utils_Tuple3(model, elm$core$Platform$Cmd$none, elm$core$Maybe$Nothing);
};
var elm$core$List$isEmpty = function (xs) {
	if (!xs.b) {
		return true;
	} else {
		return false;
	}
};
var author$project$Bottle$advance = function (model) {
	advance:
	while (true) {
		var _n0 = model.i;
		switch (_n0.$) {
			case 0:
				var pill = _n0.a;
				var _n1 = _n0.b;
				var x = _n1.a;
				var y = _n1.b;
				var newCoords = _Utils_Tuple2(x, y + 1);
				var afterPill = F2(
					function (pill_, coords) {
						var newContents = A3(author$project$Bottle$addPill, pill_, coords, model.a);
						var modify = author$project$Bottle$canSweep(newContents) ? author$project$Bottle$sweep : function (m) {
							return _Utils_update(
								m,
								{
									a: author$project$Bottle$fall(newContents)
								});
						};
						return modify(
							_Utils_update(
								model,
								{
									a: newContents,
									i: author$project$Bottle$Falling(_List_Nil)
								}));
					});
				return author$project$Bottle$withNothing(
					A3(author$project$Bottle$isAvailable, newCoords, pill, model.a) ? _Utils_update(
						model,
						{
							i: A2(author$project$Bottle$PlacingPill, pill, newCoords)
						}) : A2(
						afterPill,
						pill,
						_Utils_Tuple2(x, y)));
			case 1:
				var timeToFall = A3(
					elm$core$Basics$composeR,
					elm$core$List$isEmpty,
					elm$core$Basics$not,
					A2(
						author$project$Grid$filter,
						function (_n3) {
							var coords = _n3.d;
							return A2(author$project$Bottle$canFall, coords, model.a);
						},
						model.a));
				if (timeToFall) {
					return author$project$Bottle$withNothing(
						_Utils_update(
							model,
							{
								a: author$project$Bottle$fall(model.a)
							}));
				} else {
					if (author$project$Bottle$canSweep(model.a)) {
						return _Utils_Tuple3(
							author$project$Bottle$sweep(model),
							elm$core$Platform$Cmd$none,
							elm$core$Maybe$Nothing);
					} else {
						var _n2 = elm$core$List$head(model.n);
						if (!_n2.$) {
							var $temp$model = _Utils_update(
								model,
								{i: author$project$Bottle$Bombing});
							model = $temp$model;
							continue advance;
						} else {
							return _Utils_Tuple3(
								model,
								A2(elm$random$Random$generate, author$project$Bottle$NewPill, author$project$Bottle$generatePill),
								elm$core$Maybe$Nothing);
						}
					}
				}
			default:
				var _n4 = model.n;
				if (_n4.b) {
					var head = _n4.a;
					var tail = _n4.b;
					return _Utils_Tuple3(
						_Utils_update(
							model,
							{n: tail}),
						A2(
							elm$random$Random$generate,
							author$project$Bottle$Bomb(head),
							author$project$Bottle$generateBomb(model.a)),
						elm$core$Maybe$Nothing);
				} else {
					return _Utils_Tuple3(model, elm$core$Platform$Cmd$none, elm$core$Maybe$Nothing);
				}
		}
	}
};
var author$project$Bottle$update = F3(
	function (_n0, msg, model) {
		update:
		while (true) {
			var onBomb = _n0.ar;
			var _n1 = _Utils_Tuple2(model.i, msg);
			_n1$6:
			while (true) {
				switch (_n1.b.$) {
					case 0:
						if (_n1.a.$ === 1) {
							var cleared = _n1.a.a;
							var next = _n1.b.a;
							var _n2 = model.L;
							var a = _n2.a;
							var b = _n2.b;
							return _Utils_Tuple3(
								_Utils_update(
									model,
									{
										i: A2(
											author$project$Bottle$PlacingPill,
											A2(author$project$Bottle$Horizontal, a, b),
											_Utils_Tuple2(4, 0)),
										L: next
									}),
								elm$core$Platform$Cmd$none,
								(elm$core$List$length(cleared) > 1) ? onBomb(cleared) : elm$core$Maybe$Nothing);
						} else {
							break _n1$6;
						}
					case 1:
						if (!_n1.a.$) {
							var _n3 = _n1.a;
							var pill = _n3.a;
							var _n4 = _n3.b;
							var x = _n4.a;
							var y = _n4.b;
							var key = _n1.b.a;
							var moveIfAvailable = F2(
								function (pill_, coords) {
									return author$project$Bottle$withNothing(
										A3(author$project$Bottle$isAvailable, coords, pill_, model.a) ? _Utils_update(
											model,
											{
												i: A2(author$project$Bottle$PlacingPill, pill_, coords)
											}) : model);
								});
							if (!key.$) {
								switch (key.a) {
									case 0:
										var _n6 = key.a;
										var newPill = function () {
											if (!pill.$) {
												var a = pill.a;
												var b = pill.b;
												return A2(author$project$Bottle$Vertical, a, b);
											} else {
												var a = pill.a;
												var b = pill.b;
												return A2(author$project$Bottle$Horizontal, b, a);
											}
										}();
										return A2(
											moveIfAvailable,
											newPill,
											_Utils_Tuple2(x, y));
									case 2:
										var _n8 = key.a;
										return A2(
											moveIfAvailable,
											pill,
											_Utils_Tuple2(x - 1, y));
									case 3:
										var _n9 = key.a;
										return A2(
											moveIfAvailable,
											pill,
											_Utils_Tuple2(x + 1, y));
									default:
										var _n10 = key.a;
										return A2(
											moveIfAvailable,
											pill,
											_Utils_Tuple2(x, y + 1));
								}
							} else {
								return author$project$Bottle$withNothing(model);
							}
						} else {
							return author$project$Bottle$withNothing(model);
						}
					case 4:
						var _n11 = _n1.b.a;
						var key = _n11.a;
						var goal = _n11.b;
						var $temp$_n0 = {ar: onBomb},
							$temp$msg = author$project$Bottle$KeyDown(key),
							$temp$model = _Utils_update(
							model,
							{T: goal});
						_n0 = $temp$_n0;
						msg = $temp$msg;
						model = $temp$model;
						continue update;
					case 2:
						return author$project$Bottle$advance(model);
					default:
						if (_n1.a.$ === 2) {
							var _n12 = _n1.a;
							var _n13 = _n1.b;
							var color = _n13.a;
							var x = _n13.b;
							var contents = A3(
								author$project$Grid$setState,
								_Utils_Tuple2(
									color,
									author$project$Bottle$Pill(elm$core$Maybe$Nothing)),
								_Utils_Tuple2(x, 1),
								model.a);
							var model_ = _Utils_update(
								model,
								{a: contents});
							var _n14 = model.n;
							if (_n14.b) {
								var head = _n14.a;
								var tail = _n14.b;
								return _Utils_Tuple3(
									_Utils_update(
										model_,
										{n: tail}),
									A2(
										elm$random$Random$generate,
										author$project$Bottle$Bomb(head),
										author$project$Bottle$generateBomb(model_.a)),
									elm$core$Maybe$Nothing);
							} else {
								return _Utils_Tuple3(
									_Utils_update(
										model_,
										{
											i: author$project$Bottle$Falling(_List_Nil)
										}),
									elm$core$Platform$Cmd$none,
									elm$core$Maybe$Nothing);
							}
						} else {
							break _n1$6;
						}
				}
			}
			return author$project$Bottle$withNothing(model);
		}
	});
var author$project$Bottle$Keyboard = function (a) {
	return {$: 0, a: a};
};
var author$project$Bottle$withControls = F2(
	function (controls, model) {
		return _Utils_update(
			model,
			{
				R: author$project$Bottle$Keyboard(controls)
			});
	});
var author$project$Component$raiseOutMsg = F4(
	function (update, toModel, toMsg, result) {
		if (result.c.$ === 1) {
			var state = result.a;
			var cmd = result.b;
			var _n1 = result.c;
			return _Utils_Tuple3(
				toModel(state),
				A2(elm$core$Platform$Cmd$map, toMsg, cmd),
				elm$core$Maybe$Nothing);
		} else {
			var model_ = result.a;
			var cmd1 = result.b;
			var msg2 = result.c.a;
			var _n2 = A2(
				update,
				msg2,
				toModel(model_));
			var model__ = _n2.a;
			var cmd2 = _n2.b;
			var msg3 = _n2.c;
			return _Utils_Tuple3(
				model__,
				elm$core$Platform$Cmd$batch(
					_List_fromArray(
						[
							A2(elm$core$Platform$Cmd$map, toMsg, cmd1),
							cmd2
						])),
				msg3);
		}
	});
var author$project$Controls$arrows = function (keyCode) {
	switch (keyCode) {
		case 38:
			return elm$core$Maybe$Just(0);
		case 37:
			return elm$core$Maybe$Just(2);
		case 39:
			return elm$core$Maybe$Just(3);
		case 40:
			return elm$core$Maybe$Just(1);
		default:
			return elm$core$Maybe$Nothing;
	}
};
var author$project$Bottle$withNext = F2(
	function (next, model) {
		return _Utils_update(
			model,
			{L: next});
	});
var author$project$Bottle$Virus = {$: 0};
var author$project$Bottle$withVirus = F3(
	function (color, coords, model) {
		return _Utils_update(
			model,
			{
				a: A3(
					author$project$Grid$setState,
					_Utils_Tuple2(color, author$project$Bottle$Virus),
					coords,
					model.a)
			});
	});
var author$project$LevelCreator$NewPill = function (a) {
	return {$: 1, a: a};
};
var elm$core$Basics$min = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) < 0) ? x : y;
	});
var author$project$LevelCreator$virusesForLevel = function (level) {
	return A2(elm$core$Basics$min, 84, (4 * level) + 4);
};
var author$project$LevelCreator$update = F3(
	function (_n0, action, model) {
		var onCreated = _n0.aQ;
		var level = model.U;
		var bottle = model.y;
		if (!action.$) {
			var _n2 = action.a;
			var color = _n2.a;
			var coords = _n2.b;
			var newBottle = A3(author$project$Bottle$withVirus, color, coords, bottle);
			return A2(author$project$Bottle$isCleared, coords, newBottle.a) ? _Utils_Tuple3(
				model,
				author$project$LevelCreator$randomNewVirus(bottle.a),
				elm$core$Maybe$Nothing) : ((_Utils_cmp(
				author$project$Bottle$totalViruses(newBottle.a),
				author$project$LevelCreator$virusesForLevel(level)) > -1) ? _Utils_Tuple3(
				_Utils_update(
					model,
					{y: newBottle}),
				A2(elm$random$Random$generate, author$project$LevelCreator$NewPill, author$project$Bottle$generatePill),
				elm$core$Maybe$Nothing) : _Utils_Tuple3(
				_Utils_update(
					model,
					{y: newBottle}),
				author$project$LevelCreator$randomNewVirus(newBottle.a),
				elm$core$Maybe$Nothing));
		} else {
			var colors = action.a;
			var model_ = {
				y: A2(author$project$Bottle$withNext, colors, bottle),
				U: level
			};
			return _Utils_Tuple3(
				model_,
				elm$core$Platform$Cmd$none,
				elm$core$Maybe$Just(
					onCreated(model_)));
		}
	});
var author$project$OnePlayer$Game$LevelReady = function (a) {
	return {$: 2, a: a};
};
var author$project$OnePlayer$Game$Over = function (a) {
	return {$: 3, a: a};
};
var author$project$OnePlayer$Game$Paused = function (a) {
	return {$: 2, a: a};
};
var author$project$OnePlayer$Game$Playing = function (a) {
	return {$: 1, a: a};
};
var author$project$OnePlayer$Game$applyNtimes = F3(
	function (n, f, x) {
		return (n <= 0) ? x : ((n === 1) ? f(x) : f(
			A3(author$project$OnePlayer$Game$applyNtimes, n - 1, f, x)));
	});
var author$project$OnePlayer$Game$pointsForClearedViruses = F2(
	function (speed, cleared) {
		return (cleared > 0) ? A3(
			author$project$OnePlayer$Game$applyNtimes,
			cleared - 1,
			elm$core$Basics$mul(2),
			function () {
				switch (speed) {
					case 0:
						return 100;
					case 1:
						return 200;
					default:
						return 300;
				}
			}()) : 0;
	});
var author$project$OnePlayer$Game$update = F3(
	function (_n2, action, model) {
		update:
		while (true) {
			var onLeave = _n2.aR;
			var _n3 = _Utils_Tuple2(model, action);
			switch (_n3.a.$) {
				case 0:
					switch (_n3.b.$) {
						case 1:
							var state = _n3.a.a;
							var score = state.m;
							var creator = state.S;
							var speed = state.aa;
							var msg = _n3.b.a;
							var _n4 = A3(
								author$project$LevelCreator$update,
								{
									aQ: function (_n5) {
										var level = _n5.U;
										var bottle = _n5.y;
										return author$project$OnePlayer$Game$LevelReady(
											{y: bottle, U: level, m: score, aa: speed});
									}
								},
								msg,
								creator);
							var creator_ = _n4.a;
							var cmd = _n4.b;
							var maybeMsg = _n4.c;
							if (maybeMsg.$ === 1) {
								return _Utils_Tuple3(
									author$project$OnePlayer$Game$PrepareGame(
										_Utils_update(
											state,
											{S: creator_})),
									A2(elm$core$Platform$Cmd$map, author$project$OnePlayer$Game$CreatorMsg, cmd),
									elm$core$Maybe$Nothing);
							} else {
								var msg2 = maybeMsg.a;
								var $temp$_n2 = {aR: onLeave},
									$temp$action = msg2,
									$temp$model = author$project$OnePlayer$Game$PrepareGame(
									_Utils_update(
										state,
										{S: creator_}));
								_n2 = $temp$_n2;
								action = $temp$action;
								model = $temp$model;
								continue update;
							}
						case 2:
							var state = _n3.b.a;
							return _Utils_Tuple3(
								author$project$OnePlayer$Game$Playing(
									_Utils_update(
										state,
										{
											y: A2(author$project$Bottle$withControls, author$project$Controls$arrows, state.y)
										})),
								elm$core$Platform$Cmd$none,
								elm$core$Maybe$Nothing);
						default:
							return _Utils_Tuple3(model, elm$core$Platform$Cmd$none, elm$core$Maybe$Nothing);
					}
				case 2:
					if (_n3.b.$ === 5) {
						var state = _n3.a.a;
						var _n8 = _n3.b;
						return _Utils_Tuple3(
							author$project$OnePlayer$Game$Playing(state),
							elm$core$Platform$Cmd$none,
							elm$core$Maybe$Nothing);
					} else {
						var state = _n3.a.a;
						return _Utils_Tuple3(model, elm$core$Platform$Cmd$none, elm$core$Maybe$Nothing);
					}
				case 1:
					if (_n3.b.$ === 4) {
						var state = _n3.a.a;
						var _n7 = _n3.b;
						return _Utils_Tuple3(
							author$project$OnePlayer$Game$Paused(state),
							elm$core$Platform$Cmd$none,
							elm$core$Maybe$Nothing);
					} else {
						var state = _n3.a.a;
						var msg = _n3.b;
						return (!author$project$Bottle$totalViruses(state.y.a)) ? _Utils_Tuple3(
							author$project$OnePlayer$Game$Over(
								{A: state, V: true}),
							elm$core$Platform$Cmd$none,
							elm$core$Maybe$Nothing) : (author$project$Bottle$hasConflict(state.y) ? _Utils_Tuple3(
							author$project$OnePlayer$Game$Over(
								{A: state, V: false}),
							elm$core$Platform$Cmd$none,
							elm$core$Maybe$Nothing) : A3(author$project$OnePlayer$Game$updatePlayState, onLeave, msg, state));
					}
				default:
					switch (_n3.b.$) {
						case 3:
							var level = _n3.b.a.U;
							var score = _n3.b.a.m;
							var speed = _n3.b.a.aa;
							var _n9 = A3(author$project$OnePlayer$Game$initWithScore, level, speed, score);
							var model_ = _n9.a;
							var msg = _n9.b;
							return _Utils_Tuple3(model_, msg, elm$core$Maybe$Nothing);
						case 6:
							var _n10 = _n3.b;
							return _Utils_Tuple3(
								model,
								elm$core$Platform$Cmd$none,
								elm$core$Maybe$Just(onLeave));
						default:
							return _Utils_Tuple3(model, elm$core$Platform$Cmd$none, elm$core$Maybe$Nothing);
					}
			}
		}
	});
var author$project$OnePlayer$Game$updatePlayState = F3(
	function (onLeave, action, model) {
		var bottle = model.y;
		var speed = model.aa;
		var score = model.m;
		var withBottle = function (newBottle) {
			var sweptViruses = author$project$Bottle$totalViruses(bottle.a) - author$project$Bottle$totalViruses(newBottle.a);
			var additionalPoints = A2(author$project$OnePlayer$Game$pointsForClearedViruses, speed, sweptViruses);
			return author$project$OnePlayer$Game$Playing(
				_Utils_update(
					model,
					{y: newBottle, m: score + additionalPoints}));
		};
		if (!action.$) {
			var msg = action.a;
			return A4(
				author$project$Component$raiseOutMsg,
				author$project$OnePlayer$Game$update(
					{aR: onLeave}),
				withBottle,
				author$project$OnePlayer$Game$BottleMsg,
				A3(
					author$project$Bottle$update,
					{
						ar: function (_n1) {
							return elm$core$Maybe$Nothing;
						}
					},
					msg,
					model.y));
		} else {
			return _Utils_Tuple3(
				author$project$OnePlayer$Game$Playing(model),
				elm$core$Platform$Cmd$none,
				elm$core$Maybe$Nothing);
		}
	});
var author$project$Bottle$High = 2;
var author$project$Bottle$Low = 0;
var author$project$OnePlayer$Menu$Speed = 0;
var author$project$OnePlayer$Menu$update = F3(
	function (events, msg, state) {
		var selecting = state.E;
		var speed = state.aa;
		var withNothing = function (s) {
			return _Utils_Tuple3(s, elm$core$Platform$Cmd$none, elm$core$Maybe$Nothing);
		};
		var other = function () {
			if (!selecting) {
				return 1;
			} else {
				return 0;
			}
		}();
		switch (msg) {
			case 0:
				return withNothing(
					_Utils_update(
						state,
						{E: other}));
			case 3:
				return withNothing(
					_Utils_update(
						state,
						{E: other}));
			case 1:
				return withNothing(
					function () {
						var _n1 = _Utils_Tuple2(selecting, speed);
						if (_n1.a === 1) {
							var _n2 = _n1.a;
							return _Utils_update(
								state,
								{
									U: A2(elm$core$Basics$max, 0, state.U - 1)
								});
						} else {
							switch (_n1.b) {
								case 2:
									var _n3 = _n1.a;
									var _n4 = _n1.b;
									return _Utils_update(
										state,
										{aa: 1});
								case 1:
									var _n5 = _n1.a;
									var _n6 = _n1.b;
									return _Utils_update(
										state,
										{aa: 0});
								default:
									var _n7 = _n1.a;
									return state;
							}
						}
					}());
			case 2:
				return withNothing(
					function () {
						var _n8 = _Utils_Tuple2(selecting, speed);
						if (_n8.a === 1) {
							var _n9 = _n8.a;
							return _Utils_update(
								state,
								{
									U: A2(elm$core$Basics$min, 20, state.U + 1)
								});
						} else {
							switch (_n8.b) {
								case 0:
									var _n10 = _n8.a;
									var _n11 = _n8.b;
									return _Utils_update(
										state,
										{aa: 1});
								case 1:
									var _n12 = _n8.a;
									var _n13 = _n8.b;
									return _Utils_update(
										state,
										{aa: 2});
								default:
									var _n14 = _n8.a;
									return state;
							}
						}
					}());
			case 4:
				return _Utils_Tuple3(
					state,
					elm$core$Platform$Cmd$none,
					elm$core$Maybe$Just(
						events.aS(
							{U: state.U, aa: state.aa})));
			default:
				return withNothing(state);
		}
	});
var elm$core$Tuple$mapFirst = F2(
	function (func, _n0) {
		var x = _n0.a;
		var y = _n0.b;
		return _Utils_Tuple2(
			func(x),
			y);
	});
var author$project$OnePlayer$update = F2(
	function (action, model) {
		var _n0 = _Utils_Tuple2(model, action);
		_n0$4:
		while (true) {
			switch (_n0.b.$) {
				case 1:
					var level = _n0.b.a.U;
					var speed = _n0.b.a.aa;
					return A2(
						elm$core$Tuple$mapSecond,
						elm$core$Platform$Cmd$map(author$project$OnePlayer$GameMsg),
						A2(
							elm$core$Tuple$mapFirst,
							author$project$OnePlayer$InGame,
							A2(author$project$OnePlayer$Game$init, level, speed)));
				case 0:
					if (!_n0.a.$) {
						var state = _n0.a.a;
						var msg = _n0.b.a;
						return A4(
							author$project$Component$mapOutMsg,
							author$project$OnePlayer$update,
							author$project$OnePlayer$Init,
							author$project$OnePlayer$MenuMsg,
							A3(
								author$project$OnePlayer$Menu$update,
								{
									aS: function (_n1) {
										var level = _n1.U;
										var speed = _n1.aa;
										return author$project$OnePlayer$Start(
											{U: level, aa: speed});
									}
								},
								msg,
								state));
					} else {
						break _n0$4;
					}
				case 2:
					if (_n0.a.$ === 1) {
						var state = _n0.a.a;
						var msg = _n0.b.a;
						return A4(
							author$project$Component$mapOutMsg,
							author$project$OnePlayer$update,
							author$project$OnePlayer$InGame,
							author$project$OnePlayer$GameMsg,
							A3(
								author$project$OnePlayer$Game$update,
								{aR: author$project$OnePlayer$Reset},
								msg,
								state));
					} else {
						break _n0$4;
					}
				default:
					if (_n0.a.$ === 1) {
						var state = _n0.a.a;
						var _n2 = _n0.b;
						return _Utils_Tuple2(
							author$project$OnePlayer$Init(author$project$OnePlayer$Menu$init),
							elm$core$Platform$Cmd$none);
					} else {
						break _n0$4;
					}
			}
		}
		return _Utils_Tuple2(model, elm$core$Platform$Cmd$none);
	});
var author$project$TwoPlayer$Init = function (a) {
	return {$: 0, a: a};
};
var author$project$TwoPlayer$init = _Utils_Tuple2(
	author$project$TwoPlayer$Init(author$project$OnePlayer$Menu$init),
	elm$core$Platform$Cmd$none);
var author$project$TwoPlayer$InGame = function (a) {
	return {$: 1, a: a};
};
var author$project$TwoPlayer$Reset = {$: 3};
var author$project$TwoPlayer$Start = function (a) {
	return {$: 0, a: a};
};
var author$project$TwoPlayer$Game$CreatorMsg = function (a) {
	return {$: 2, a: a};
};
var author$project$TwoPlayer$Game$PrepareFirst = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var author$project$TwoPlayer$Game$init = F2(
	function (first, second) {
		var withOpts = function (opts) {
			return {y: author$project$Bottle$init, U: opts.U, aa: opts.aa};
		};
		var _n0 = author$project$LevelCreator$init(first.U);
		var creator = _n0.a;
		var cmd = _n0.b;
		return _Utils_Tuple2(
			A2(
				author$project$TwoPlayer$Game$PrepareFirst,
				{
					g: withOpts(first),
					e: withOpts(second)
				},
				creator),
			A2(elm$core$Platform$Cmd$map, author$project$TwoPlayer$Game$CreatorMsg, cmd));
	});
var author$project$Bottle$withBombs = F2(
	function (colors, model) {
		return _Utils_update(
			model,
			{
				n: _Utils_ap(model.n, colors)
			});
	});
var author$project$TwoPlayer$Game$First = 0;
var author$project$TwoPlayer$Game$FirstBomb = function (a) {
	return {$: 4, a: a};
};
var author$project$TwoPlayer$Game$LevelReady = function (a) {
	return {$: 3, a: a};
};
var author$project$TwoPlayer$Game$Over = function (a) {
	return {$: 4, a: a};
};
var author$project$TwoPlayer$Game$Paused = function (a) {
	return {$: 3, a: a};
};
var author$project$TwoPlayer$Game$Playing = function (a) {
	return {$: 2, a: a};
};
var author$project$TwoPlayer$Game$PrepareSecond = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var author$project$TwoPlayer$Game$Second = 1;
var author$project$TwoPlayer$Game$SecondBomb = function (a) {
	return {$: 5, a: a};
};
var author$project$TwoPlayer$Game$withBottle = F2(
	function (newBottle, player) {
		return _Utils_update(
			player,
			{y: newBottle});
	});
var author$project$TwoPlayer$Game$update = F3(
	function (_n1, action, model) {
		update:
		while (true) {
			var onLeave = _n1.aR;
			var _n2 = _Utils_Tuple2(model, action);
			switch (_n2.a.$) {
				case 0:
					switch (_n2.b.$) {
						case 2:
							var _n3 = _n2.a;
							var state = _n3.a;
							var creator = _n3.b;
							var msg = _n2.b.a;
							var first = state.g;
							var _n4 = A3(
								author$project$LevelCreator$update,
								{
									aQ: function (_n5) {
										var level = _n5.U;
										var bottle = _n5.y;
										return author$project$TwoPlayer$Game$LevelReady(
											_Utils_update(
												state,
												{
													g: _Utils_update(
														first,
														{y: bottle})
												}));
									}
								},
								msg,
								creator);
							var creator_ = _n4.a;
							var cmd = _n4.b;
							var maybeMsg = _n4.c;
							if (maybeMsg.$ === 1) {
								return _Utils_Tuple3(
									A2(author$project$TwoPlayer$Game$PrepareFirst, state, creator_),
									A2(elm$core$Platform$Cmd$map, author$project$TwoPlayer$Game$CreatorMsg, cmd),
									elm$core$Maybe$Nothing);
							} else {
								var msg2 = maybeMsg.a;
								var $temp$_n1 = {aR: onLeave},
									$temp$action = msg2,
									$temp$model = A2(author$project$TwoPlayer$Game$PrepareFirst, state, creator_);
								_n1 = $temp$_n1;
								action = $temp$action;
								model = $temp$model;
								continue update;
							}
						case 3:
							var _n7 = _n2.a;
							var creator = _n7.b;
							var state = _n2.b.a;
							var _n8 = author$project$LevelCreator$init(state.e.U);
							var creator_ = _n8.a;
							var cmd = _n8.b;
							return _Utils_Tuple3(
								A2(author$project$TwoPlayer$Game$PrepareSecond, state, creator_),
								A2(elm$core$Platform$Cmd$map, author$project$TwoPlayer$Game$CreatorMsg, cmd),
								elm$core$Maybe$Nothing);
						default:
							var _n9 = _n2.a;
							return _Utils_Tuple3(model, elm$core$Platform$Cmd$none, elm$core$Maybe$Nothing);
					}
				case 1:
					switch (_n2.b.$) {
						case 2:
							var _n10 = _n2.a;
							var state = _n10.a;
							var creator = _n10.b;
							var msg = _n2.b.a;
							var second = state.e;
							var _n11 = A3(
								author$project$LevelCreator$update,
								{
									aQ: function (_n12) {
										var level = _n12.U;
										var bottle = _n12.y;
										return author$project$TwoPlayer$Game$LevelReady(
											_Utils_update(
												state,
												{
													e: _Utils_update(
														second,
														{
															y: A2(author$project$Bottle$withControls, author$project$Controls$arrows, bottle)
														})
												}));
									}
								},
								msg,
								creator);
							var creator_ = _n11.a;
							var cmd = _n11.b;
							var maybeMsg = _n11.c;
							if (_Utils_eq(state.g.U, state.e.U)) {
								return _Utils_Tuple3(
									author$project$TwoPlayer$Game$Playing(
										_Utils_update(
											state,
											{
												e: _Utils_update(
													second,
													{
														y: A2(author$project$Bottle$withControls, author$project$Controls$arrows, state.g.y)
													})
											})),
									elm$core$Platform$Cmd$none,
									elm$core$Maybe$Nothing);
							} else {
								if (maybeMsg.$ === 1) {
									return _Utils_Tuple3(
										A2(author$project$TwoPlayer$Game$PrepareSecond, state, creator_),
										A2(elm$core$Platform$Cmd$map, author$project$TwoPlayer$Game$CreatorMsg, cmd),
										elm$core$Maybe$Nothing);
								} else {
									var msg2 = maybeMsg.a;
									var $temp$_n1 = {aR: onLeave},
										$temp$action = msg2,
										$temp$model = A2(author$project$TwoPlayer$Game$PrepareSecond, state, creator_);
									_n1 = $temp$_n1;
									action = $temp$action;
									model = $temp$model;
									continue update;
								}
							}
						case 3:
							var _n14 = _n2.a;
							var creator = _n14.b;
							var state = _n2.b.a;
							return _Utils_Tuple3(
								author$project$TwoPlayer$Game$Playing(state),
								elm$core$Platform$Cmd$none,
								elm$core$Maybe$Nothing);
						default:
							var _n15 = _n2.a;
							return _Utils_Tuple3(model, elm$core$Platform$Cmd$none, elm$core$Maybe$Nothing);
					}
				case 3:
					if (_n2.b.$ === 7) {
						var state = _n2.a.a;
						var _n17 = _n2.b;
						return _Utils_Tuple3(
							author$project$TwoPlayer$Game$Playing(state),
							elm$core$Platform$Cmd$none,
							elm$core$Maybe$Nothing);
					} else {
						var state = _n2.a.a;
						return _Utils_Tuple3(model, elm$core$Platform$Cmd$none, elm$core$Maybe$Nothing);
					}
				case 2:
					switch (_n2.b.$) {
						case 6:
							var state = _n2.a.a;
							var _n16 = _n2.b;
							return _Utils_Tuple3(
								author$project$TwoPlayer$Game$Paused(state),
								elm$core$Platform$Cmd$none,
								elm$core$Maybe$Nothing);
						case 4:
							var state = _n2.a.a;
							var colors = _n2.b.a;
							return _Utils_Tuple3(
								author$project$TwoPlayer$Game$Playing(
									_Utils_update(
										state,
										{
											e: A2(
												author$project$TwoPlayer$Game$withBottle,
												A2(author$project$Bottle$withBombs, colors, state.e.y),
												state.e)
										})),
								elm$core$Platform$Cmd$none,
								elm$core$Maybe$Nothing);
						case 5:
							var state = _n2.a.a;
							var colors = _n2.b.a;
							return _Utils_Tuple3(
								author$project$TwoPlayer$Game$Playing(
									_Utils_update(
										state,
										{
											g: A2(
												author$project$TwoPlayer$Game$withBottle,
												A2(author$project$Bottle$withBombs, colors, state.g.y),
												state.g)
										})),
								elm$core$Platform$Cmd$none,
								elm$core$Maybe$Nothing);
						default:
							var state = _n2.a.a;
							var first = state.g;
							var second = state.e;
							var msg = _n2.b;
							return ((!author$project$Bottle$totalViruses(first.y.a)) || author$project$Bottle$hasConflict(second.y)) ? _Utils_Tuple3(
								author$project$TwoPlayer$Game$Over(
									{A: state, ad: 0}),
								elm$core$Platform$Cmd$none,
								elm$core$Maybe$Nothing) : (((!author$project$Bottle$totalViruses(second.y.a)) || author$project$Bottle$hasConflict(first.y)) ? _Utils_Tuple3(
								author$project$TwoPlayer$Game$Over(
									{A: state, ad: 1}),
								elm$core$Platform$Cmd$none,
								elm$core$Maybe$Nothing) : A3(author$project$TwoPlayer$Game$updatePlayState, onLeave, msg, state));
					}
				default:
					if (_n2.b.$ === 8) {
						var _n18 = _n2.b;
						return _Utils_Tuple3(
							model,
							elm$core$Platform$Cmd$none,
							elm$core$Maybe$Just(onLeave));
					} else {
						return _Utils_Tuple3(model, elm$core$Platform$Cmd$none, elm$core$Maybe$Nothing);
					}
			}
		}
	});
var author$project$TwoPlayer$Game$updatePlayState = F3(
	function (onLeave, action, model) {
		var first = model.g;
		var second = model.e;
		switch (action.$) {
			case 0:
				var msg = action.a;
				return A4(
					author$project$Component$raiseOutMsg,
					author$project$TwoPlayer$Game$update(
						{aR: onLeave}),
					function (bottle) {
						return author$project$TwoPlayer$Game$Playing(
							_Utils_update(
								model,
								{
									g: A2(author$project$TwoPlayer$Game$withBottle, bottle, first)
								}));
					},
					author$project$TwoPlayer$Game$FirstBottleMsg,
					A3(
						author$project$Bottle$update,
						{
							ar: A2(elm$core$Basics$composeR, author$project$TwoPlayer$Game$FirstBomb, elm$core$Maybe$Just)
						},
						msg,
						first.y));
			case 1:
				var msg = action.a;
				return A4(
					author$project$Component$raiseOutMsg,
					author$project$TwoPlayer$Game$update(
						{aR: onLeave}),
					function (bottle) {
						return author$project$TwoPlayer$Game$Playing(
							_Utils_update(
								model,
								{
									e: A2(author$project$TwoPlayer$Game$withBottle, bottle, second)
								}));
					},
					author$project$TwoPlayer$Game$SecondBottleMsg,
					A3(
						author$project$Bottle$update,
						{
							ar: A2(elm$core$Basics$composeR, author$project$TwoPlayer$Game$SecondBomb, elm$core$Maybe$Just)
						},
						msg,
						second.y));
			default:
				return _Utils_Tuple3(
					author$project$TwoPlayer$Game$Playing(model),
					elm$core$Platform$Cmd$none,
					elm$core$Maybe$Nothing);
		}
	});
var author$project$TwoPlayer$update = F2(
	function (action, model) {
		var _n0 = _Utils_Tuple2(model, action);
		_n0$4:
		while (true) {
			if (!_n0.a.$) {
				switch (_n0.b.$) {
					case 0:
						var level = _n0.b.a.U;
						var speed = _n0.b.a.aa;
						return A2(
							elm$core$Tuple$mapSecond,
							elm$core$Platform$Cmd$map(author$project$TwoPlayer$GameMsg),
							A2(
								elm$core$Tuple$mapFirst,
								author$project$TwoPlayer$InGame,
								A2(
									author$project$TwoPlayer$Game$init,
									{U: level, aa: speed},
									{U: level, aa: speed})));
					case 1:
						var state = _n0.a.a;
						var msg = _n0.b.a;
						return A4(
							author$project$Component$mapOutMsg,
							author$project$TwoPlayer$update,
							author$project$TwoPlayer$Init,
							author$project$TwoPlayer$MenuMsg,
							A3(
								author$project$OnePlayer$Menu$update,
								{
									aS: function (_n1) {
										var level = _n1.U;
										var speed = _n1.aa;
										return author$project$TwoPlayer$Start(
											{U: level, aa: speed});
									}
								},
								msg,
								state));
					default:
						break _n0$4;
				}
			} else {
				switch (_n0.b.$) {
					case 2:
						var state = _n0.a.a;
						var msg = _n0.b.a;
						return A4(
							author$project$Component$mapOutMsg,
							author$project$TwoPlayer$update,
							author$project$TwoPlayer$InGame,
							author$project$TwoPlayer$GameMsg,
							A3(
								author$project$TwoPlayer$Game$update,
								{aR: author$project$TwoPlayer$Reset},
								msg,
								state));
					case 3:
						var state = _n0.a.a;
						var _n2 = _n0.b;
						return _Utils_Tuple2(
							author$project$TwoPlayer$Init(author$project$OnePlayer$Menu$init),
							elm$core$Platform$Cmd$none);
					default:
						break _n0$4;
				}
			}
		}
		return _Utils_Tuple2(model, elm$core$Platform$Cmd$none);
	});
var author$project$Main$update = F2(
	function (msg, model) {
		var _n0 = _Utils_Tuple2(model, msg);
		_n0$4:
		while (true) {
			switch (_n0.a.$) {
				case 0:
					switch (_n0.b.$) {
						case 2:
							var _n1 = _n0.a;
							var _n2 = _n0.b;
							return A2(
								elm$core$Tuple$mapSecond,
								elm$core$Platform$Cmd$map(author$project$Main$OneMsg),
								A2(elm$core$Tuple$mapFirst, author$project$Main$One, author$project$OnePlayer$init));
						case 3:
							var _n3 = _n0.a;
							var _n4 = _n0.b;
							return A2(
								elm$core$Tuple$mapSecond,
								elm$core$Platform$Cmd$map(author$project$Main$TwoMsg),
								A2(elm$core$Tuple$mapFirst, author$project$Main$Two, author$project$TwoPlayer$init));
						default:
							break _n0$4;
					}
				case 1:
					if (!_n0.b.$) {
						var state = _n0.a.a;
						var msg_ = _n0.b.a;
						return A4(
							author$project$Component$mapSimple,
							author$project$Main$update,
							author$project$Main$One,
							author$project$Main$OneMsg,
							A2(author$project$OnePlayer$update, msg_, state));
					} else {
						break _n0$4;
					}
				default:
					if (_n0.b.$ === 1) {
						var state = _n0.a.a;
						var msg_ = _n0.b.a;
						return A4(
							author$project$Component$mapSimple,
							author$project$Main$update,
							author$project$Main$Two,
							author$project$Main$TwoMsg,
							A2(author$project$TwoPlayer$update, msg_, state));
					} else {
						break _n0$4;
					}
			}
		}
		return _Utils_Tuple2(model, elm$core$Platform$Cmd$none);
	});
var author$project$Main$PlayOne = {$: 2};
var author$project$Main$PlayTwo = {$: 3};
var elm$html$Html$button = _VirtualDom_node('button');
var elm$html$Html$div = _VirtualDom_node('div');
var elm$virtual_dom$VirtualDom$text = _VirtualDom_text;
var elm$html$Html$text = elm$virtual_dom$VirtualDom$text;
var elm$virtual_dom$VirtualDom$Normal = function (a) {
	return {$: 0, a: a};
};
var elm$virtual_dom$VirtualDom$on = _VirtualDom_on;
var elm$html$Html$Events$on = F2(
	function (event, decoder) {
		return A2(
			elm$virtual_dom$VirtualDom$on,
			event,
			elm$virtual_dom$VirtualDom$Normal(decoder));
	});
var elm$html$Html$Events$onClick = function (msg) {
	return A2(
		elm$html$Html$Events$on,
		'click',
		elm$json$Json$Decode$succeed(msg));
};
var author$project$Main$viewSelecting = A2(
	elm$html$Html$div,
	_List_Nil,
	_List_fromArray(
		[
			A2(
			elm$html$Html$button,
			_List_fromArray(
				[
					elm$html$Html$Events$onClick(author$project$Main$PlayOne)
				]),
			_List_fromArray(
				[
					elm$html$Html$text('1p')
				])),
			A2(
			elm$html$Html$button,
			_List_fromArray(
				[
					elm$html$Html$Events$onClick(author$project$Main$PlayTwo)
				]),
			_List_fromArray(
				[
					elm$html$Html$text('2p')
				]))
		]));
var author$project$Element$none = elm$html$Html$text('');
var author$project$OnePlayer$Game$Advance = function (a) {
	return {$: 3, a: a};
};
var author$project$OnePlayer$Game$Pause = {$: 4};
var author$project$OnePlayer$Game$Reset = {$: 6};
var author$project$OnePlayer$Game$Resume = {$: 5};
var elm$html$Html$h3 = _VirtualDom_node('h3');
var elm$virtual_dom$VirtualDom$style = _VirtualDom_style;
var elm$html$Html$Attributes$style = elm$virtual_dom$VirtualDom$style;
var author$project$OnePlayer$Game$viewMessage = F2(
	function (message, below) {
		return A2(
			elm$html$Html$div,
			_List_fromArray(
				[
					A2(elm$html$Html$Attributes$style, 'text-align', 'center'),
					A2(elm$html$Html$Attributes$style, 'margin', '16px 0')
				]),
			_List_fromArray(
				[
					A2(
					elm$html$Html$h3,
					_List_Nil,
					_List_fromArray(
						[
							elm$html$Html$text(message)
						])),
					below
				]));
	});
var author$project$Bottle$speedToString = function (s) {
	switch (s) {
		case 0:
			return 'Low';
		case 1:
			return 'Med';
		default:
			return 'High';
	}
};
var author$project$Bottle$cellSize = 24;
var author$project$Element$px = function (x) {
	return elm$core$String$fromInt(x) + 'px';
};
var author$project$Bottle$cellStyle = _List_fromArray(
	[
		A2(
		elm$html$Html$Attributes$style,
		'width',
		author$project$Element$px(author$project$Bottle$cellSize)),
		A2(
		elm$html$Html$Attributes$style,
		'height',
		author$project$Element$px(author$project$Bottle$cellSize)),
		A2(elm$html$Html$Attributes$style, 'border', '1px solid black')
	]);
var author$project$Bottle$viewColor = F3(
	function (color, radius, extraStyle) {
		var bg = function () {
			switch (color) {
				case 0:
					return '#e8005a';
				case 1:
					return '#39bdff';
				default:
					return '#ffbd03';
			}
		}();
		return elm$html$Html$div(
			_Utils_ap(
				_List_fromArray(
					[
						A2(elm$html$Html$Attributes$style, 'background-color', bg),
						A2(
						elm$html$Html$Attributes$style,
						'border-top-left-radius',
						author$project$Element$px(radius)),
						A2(
						elm$html$Html$Attributes$style,
						'border-top-right-radius',
						author$project$Element$px(radius)),
						A2(
						elm$html$Html$Attributes$style,
						'border-bottom-left-radius',
						author$project$Element$px(radius)),
						A2(
						elm$html$Html$Attributes$style,
						'border-bottom-right-radius',
						author$project$Element$px(radius))
					]),
				_Utils_ap(author$project$Bottle$cellStyle, extraStyle)));
	});
var author$project$Bottle$viewPill = F2(
	function (dependent, color) {
		return A4(
			author$project$Bottle$viewColor,
			color,
			8,
			function () {
				if (!dependent.$) {
					switch (dependent.a) {
						case 0:
							var _n1 = dependent.a;
							return _List_fromArray(
								[
									A2(
									elm$html$Html$Attributes$style,
									'border-top-left-radius',
									author$project$Element$px(0)),
									A2(
									elm$html$Html$Attributes$style,
									'border-top-right-radius',
									author$project$Element$px(0))
								]);
						case 1:
							var _n2 = dependent.a;
							return _List_fromArray(
								[
									A2(
									elm$html$Html$Attributes$style,
									'border-bottom-left-radius',
									author$project$Element$px(0)),
									A2(
									elm$html$Html$Attributes$style,
									'border-bottom-right-radius',
									author$project$Element$px(0))
								]);
						case 2:
							var _n3 = dependent.a;
							return _List_fromArray(
								[
									A2(
									elm$html$Html$Attributes$style,
									'border-top-left-radius',
									author$project$Element$px(0)),
									A2(
									elm$html$Html$Attributes$style,
									'border-bottom-left-radius',
									author$project$Element$px(0))
								]);
						default:
							var _n4 = dependent.a;
							return _List_fromArray(
								[
									A2(
									elm$html$Html$Attributes$style,
									'border-top-right-radius',
									author$project$Element$px(0)),
									A2(
									elm$html$Html$Attributes$style,
									'border-bottom-right-radius',
									author$project$Element$px(0))
								]);
					}
				} else {
					return _List_Nil;
				}
			}(),
			_List_Nil);
	});
var author$project$Bottle$viewVirus = function (color) {
	return A4(
		author$project$Bottle$viewColor,
		color,
		3,
		_List_Nil,
		_List_fromArray(
			[
				elm$html$Html$text('◔̯◔')
			]));
};
var author$project$Bottle$view = function (_n0) {
	var contents = _n0.a;
	var mode = _n0.i;
	var goal = _n0.T;
	return A2(
		elm$html$Html$div,
		_List_Nil,
		_List_fromArray(
			[
				A2(
				elm$html$Html$div,
				_List_fromArray(
					[
						A2(elm$html$Html$Attributes$style, 'display', 'inline-block'),
						A2(elm$html$Html$Attributes$style, 'border', '3px solid #CCC'),
						A2(elm$html$Html$Attributes$style, 'border-radius', '3px'),
						A2(elm$html$Html$Attributes$style, 'background', '#000')
					]),
				A2(
					elm$core$List$map,
					function (column) {
						return A2(
							elm$html$Html$div,
							_List_fromArray(
								[
									A2(elm$html$Html$Attributes$style, 'display', 'inline-block'),
									A2(elm$html$Html$Attributes$style, 'vertical-align', 'top')
								]),
							A2(
								elm$core$List$map,
								function (cell) {
									var _n1 = cell.b;
									if (_n1.$ === 1) {
										return A2(elm$html$Html$div, author$project$Bottle$cellStyle, _List_Nil);
									} else {
										if (_n1.a.b.$ === 1) {
											var _n2 = _n1.a;
											var color = _n2.a;
											var dependent = _n2.b.a;
											return A2(author$project$Bottle$viewPill, dependent, color);
										} else {
											var _n3 = _n1.a;
											var color = _n3.a;
											var _n4 = _n3.b;
											return author$project$Bottle$viewVirus(color);
										}
									}
								},
								column));
					},
					function () {
						if (!mode.$) {
							var pill = mode.a;
							var coords = mode.b;
							var withGoal = function () {
								if (goal.$ === 1) {
									return contents;
								} else {
									var _n7 = goal.a;
									var x = _n7.a;
									var p = _n7.b;
									return A3(
										author$project$Bottle$addPill,
										p,
										_Utils_Tuple2(x, 0),
										contents);
								}
							}();
							return A3(author$project$Bottle$addPill, pill, coords, contents);
						} else {
							return contents;
						}
					}()))
			]));
};
var author$project$Element$styled = F2(
	function (el, css) {
		return F2(
			function (attrs, children) {
				return A2(
					el,
					_Utils_ap(
						A2(
							elm$core$List$map,
							function (_n0) {
								var k = _n0.a;
								var v = _n0.b;
								return A2(elm$html$Html$Attributes$style, k, v);
							},
							css),
						attrs),
					children);
			});
	});
var author$project$OnePlayer$Game$columnEl = A2(
	author$project$Element$styled,
	elm$html$Html$div,
	_List_fromArray(
		[
			_Utils_Tuple2('margin', '0 16px')
		]));
var elm$html$Html$p = _VirtualDom_node('p');
var author$project$OnePlayer$Game$viewPlaying = F2(
	function (pauseMsg, _n0) {
		var score = _n0.m;
		var bottle = _n0.y;
		var level = _n0.U;
		var speed = _n0.aa;
		return A2(
			elm$html$Html$div,
			_List_fromArray(
				[
					A2(elm$html$Html$Attributes$style, 'display', 'flex')
				]),
			_List_fromArray(
				[
					A2(
					author$project$OnePlayer$Game$columnEl,
					_List_Nil,
					_List_fromArray(
						[
							A2(
							elm$html$Html$h3,
							_List_Nil,
							_List_fromArray(
								[
									elm$html$Html$text('score')
								])),
							A2(
							elm$html$Html$p,
							_List_fromArray(
								[
									A2(elm$html$Html$Attributes$style, 'text-align', 'right')
								]),
							_List_fromArray(
								[
									A2(elm$core$Basics$composeR, elm$core$String$fromInt, elm$html$Html$text)(score)
								])),
							A2(
							elm$core$Maybe$withDefault,
							author$project$Element$none,
							A2(
								elm$core$Maybe$map,
								function (msg) {
									return A2(
										elm$html$Html$button,
										_List_fromArray(
											[
												elm$html$Html$Events$onClick(msg)
											]),
										_List_fromArray(
											[
												elm$html$Html$text('pause')
											]));
								},
								pauseMsg))
						])),
					author$project$Bottle$view(bottle),
					A2(
					author$project$OnePlayer$Game$columnEl,
					_List_Nil,
					_List_fromArray(
						[
							A2(
							elm$html$Html$h3,
							_List_Nil,
							_List_fromArray(
								[
									elm$html$Html$text('next')
								])),
							A2(
							elm$html$Html$div,
							_List_fromArray(
								[
									A2(elm$html$Html$Attributes$style, 'display', 'flex')
								]),
							_List_fromArray(
								[
									A2(
									elm$core$Basics$composeR,
									elm$core$Tuple$first,
									author$project$Bottle$viewPill(
										elm$core$Maybe$Just(3)))(bottle.L),
									A2(
									elm$core$Basics$composeR,
									elm$core$Tuple$second,
									author$project$Bottle$viewPill(
										elm$core$Maybe$Just(2)))(bottle.L)
								])),
							A2(
							elm$html$Html$div,
							_List_fromArray(
								[
									A2(elm$html$Html$Attributes$style, 'margin', '72px 0')
								]),
							_List_fromArray(
								[
									A2(
									elm$html$Html$h3,
									_List_Nil,
									_List_fromArray(
										[
											elm$html$Html$text('level')
										])),
									A2(
									elm$html$Html$p,
									_List_Nil,
									_List_fromArray(
										[
											A2(elm$core$Basics$composeR, elm$core$String$fromInt, elm$html$Html$text)(level)
										])),
									A2(
									elm$html$Html$h3,
									_List_Nil,
									_List_fromArray(
										[
											elm$html$Html$text('speed')
										])),
									A2(
									elm$html$Html$p,
									_List_Nil,
									_List_fromArray(
										[
											A2(elm$core$Basics$composeR, author$project$Bottle$speedToString, elm$html$Html$text)(speed)
										])),
									A2(
									elm$html$Html$h3,
									_List_Nil,
									_List_fromArray(
										[
											elm$html$Html$text('virus')
										])),
									A2(
									elm$html$Html$p,
									_List_Nil,
									_List_fromArray(
										[
											elm$html$Html$text(
											elm$core$String$fromInt(
												author$project$Bottle$totalViruses(bottle.a)))
										]))
								]))
						]))
				]));
	});
var author$project$OnePlayer$Game$view = function (model) {
	switch (model.$) {
		case 0:
			return A2(
				elm$html$Html$div,
				_List_Nil,
				_List_fromArray(
					[
						elm$html$Html$text('💊💊💊')
					]));
		case 1:
			var state = model.a;
			return A2(
				author$project$OnePlayer$Game$viewPlaying,
				elm$core$Maybe$Just(author$project$OnePlayer$Game$Pause),
				state);
		case 2:
			var state = model.a;
			return A2(
				elm$html$Html$div,
				_List_Nil,
				_List_fromArray(
					[
						A2(
						author$project$OnePlayer$Game$viewMessage,
						'Paused',
						A2(
							elm$html$Html$button,
							_List_fromArray(
								[
									elm$html$Html$Events$onClick(author$project$OnePlayer$Game$Resume)
								]),
							_List_fromArray(
								[
									elm$html$Html$text('resume')
								])))
					]));
		default:
			var state = model.a;
			return A2(
				elm$html$Html$div,
				_List_Nil,
				_List_fromArray(
					[
						A2(
						author$project$OnePlayer$Game$viewMessage,
						state.V ? 'You Win!' : 'Game Over',
						A2(
							elm$html$Html$div,
							_List_Nil,
							_List_fromArray(
								[
									state.V ? A2(
									elm$html$Html$button,
									_List_fromArray(
										[
											elm$html$Html$Events$onClick(
											author$project$OnePlayer$Game$Advance(
												{U: state.A.U + 1, m: state.A.m, aa: state.A.aa}))
										]),
									_List_fromArray(
										[
											elm$html$Html$text('Next Level')
										])) : author$project$Element$none,
									A2(
									elm$html$Html$button,
									_List_fromArray(
										[
											elm$html$Html$Events$onClick(author$project$OnePlayer$Game$Reset)
										]),
									_List_fromArray(
										[
											elm$html$Html$text('Main Menu')
										]))
								]))),
						A2(author$project$OnePlayer$Game$viewPlaying, elm$core$Maybe$Nothing, state.A)
					]));
	}
};
var author$project$OnePlayer$Menu$btw = A2(
	author$project$Element$styled,
	elm$html$Html$p,
	_List_fromArray(
		[
			_Utils_Tuple2('font-color', '#666'),
			_Utils_Tuple2('text-align', 'center')
		]));
var author$project$OnePlayer$Menu$heading = F2(
	function (selected, str) {
		return A2(
			elm$html$Html$h3,
			_List_Nil,
			_List_fromArray(
				[
					elm$html$Html$text(
					selected ? ('>' + (str + '<')) : str)
				]));
	});
var author$project$OnePlayer$Menu$row = A2(
	author$project$Element$styled,
	elm$html$Html$div,
	_List_fromArray(
		[
			_Utils_Tuple2('margin-bottom', '48px')
		]));
var elm$core$Basics$modBy = _Basics_modBy;
var author$project$OnePlayer$Menu$viewLevelSlider = function (level) {
	return A2(
		elm$html$Html$div,
		_List_fromArray(
			[
				A2(elm$html$Html$Attributes$style, 'display', 'flex'),
				A2(elm$html$Html$Attributes$style, 'justify-content', 'space-between'),
				A2(elm$html$Html$Attributes$style, 'align-items', 'center')
			]),
		A2(
			elm$core$List$map,
			function (n) {
				return A2(
					elm$html$Html$div,
					_List_fromArray(
						[
							A2(
							elm$html$Html$Attributes$style,
							'height',
							author$project$Element$px(
								(!A2(elm$core$Basics$modBy, 5, n)) ? 16 : 8)),
							A2(elm$html$Html$Attributes$style, 'width', '4px'),
							A2(
							elm$html$Html$Attributes$style,
							'background',
							_Utils_eq(n, level) ? '#fb7c54' : '#000')
						]),
					_List_Nil);
			},
			A2(elm$core$List$range, 0, 20)));
};
var elm$html$Html$h4 = _VirtualDom_node('h4');
var author$project$OnePlayer$Menu$viewLevel = function (level) {
	return A2(
		elm$html$Html$div,
		_List_fromArray(
			[
				A2(elm$html$Html$Attributes$style, 'padding', '0 24px')
			]),
		_List_fromArray(
			[
				A2(
				elm$html$Html$h4,
				_List_fromArray(
					[
						A2(elm$html$Html$Attributes$style, 'text-align', 'right')
					]),
				_List_fromArray(
					[
						A2(elm$core$Basics$composeR, elm$core$String$fromInt, elm$html$Html$text)(level)
					])),
				author$project$OnePlayer$Menu$viewLevelSlider(level)
			]));
};
var author$project$OnePlayer$Menu$viewSpeed = F2(
	function (ideal, real) {
		return A2(
			elm$html$Html$h4,
			_List_fromArray(
				[
					A2(elm$html$Html$Attributes$style, 'padding', '4px 8px'),
					_Utils_eq(real, ideal) ? A2(elm$html$Html$Attributes$style, 'border', '3px solid #fb7c54') : A2(elm$html$Html$Attributes$style, '', '')
				]),
			_List_fromArray(
				[
					A2(elm$core$Basics$composeR, author$project$Bottle$speedToString, elm$html$Html$text)(real)
				]));
	});
var author$project$OnePlayer$Menu$view = function (_n0) {
	var level = _n0.U;
	var speed = _n0.aa;
	var selecting = _n0.E;
	return A2(
		elm$html$Html$div,
		_List_fromArray(
			[
				A2(elm$html$Html$Attributes$style, 'width', '420px'),
				A2(elm$html$Html$Attributes$style, 'max-width', '100%')
			]),
		_List_fromArray(
			[
				A2(
				author$project$OnePlayer$Menu$row,
				_List_Nil,
				_List_fromArray(
					[
						A2(author$project$OnePlayer$Menu$heading, selecting === 1, 'virus level'),
						author$project$OnePlayer$Menu$viewLevel(level)
					])),
				A2(
				author$project$OnePlayer$Menu$row,
				_List_Nil,
				_List_fromArray(
					[
						A2(author$project$OnePlayer$Menu$heading, !selecting, 'speed'),
						A2(
						elm$html$Html$div,
						_List_fromArray(
							[
								A2(elm$html$Html$Attributes$style, 'width', '100%'),
								A2(elm$html$Html$Attributes$style, 'display', 'flex'),
								A2(elm$html$Html$Attributes$style, 'justify-content', 'space-around')
							]),
						A2(
							elm$core$List$map,
							author$project$OnePlayer$Menu$viewSpeed(speed),
							_List_fromArray(
								[0, 1, 2])))
					])),
				A2(
				author$project$OnePlayer$Menu$btw,
				_List_Nil,
				_List_fromArray(
					[
						elm$html$Html$text('use arrows, hit enter')
					]))
			]));
};
var elm$virtual_dom$VirtualDom$map = _VirtualDom_map;
var elm$html$Html$map = elm$virtual_dom$VirtualDom$map;
var author$project$OnePlayer$view = function (model) {
	if (!model.$) {
		var state = model.a;
		return author$project$OnePlayer$Menu$view(state);
	} else {
		var state = model.a;
		return A2(
			elm$html$Html$map,
			author$project$OnePlayer$GameMsg,
			author$project$OnePlayer$Game$view(state));
	}
};
var author$project$TwoPlayer$Game$Reset = {$: 8};
var author$project$TwoPlayer$Game$Resume = {$: 7};
var author$project$TwoPlayer$Game$displayViruses = function (player) {
	return elm$core$String$fromInt(
		author$project$Bottle$totalViruses(player.y.a));
};
var author$project$TwoPlayer$Game$spaceBetween = A2(
	author$project$Element$styled,
	elm$html$Html$p,
	_List_fromArray(
		[
			_Utils_Tuple2('display', 'flex'),
			_Utils_Tuple2('justify-content', 'space-between')
		]));
var author$project$TwoPlayer$Game$viewMessage = F2(
	function (message, below) {
		return A2(
			elm$html$Html$div,
			_List_fromArray(
				[
					A2(elm$html$Html$Attributes$style, 'text-align', 'center'),
					A2(elm$html$Html$Attributes$style, 'margin', '16px 0')
				]),
			_List_fromArray(
				[
					A2(
					elm$html$Html$h3,
					_List_Nil,
					_List_fromArray(
						[
							elm$html$Html$text(message)
						])),
					below
				]));
	});
var author$project$TwoPlayer$Game$viewPlayer = function (_n0) {
	var bottle = _n0.y;
	var level = _n0.U;
	var speed = _n0.aa;
	return A2(
		elm$html$Html$div,
		_List_fromArray(
			[
				A2(elm$html$Html$Attributes$style, 'display', 'flex'),
				A2(elm$html$Html$Attributes$style, 'flex-direction', 'column'),
				A2(elm$html$Html$Attributes$style, 'align-items', 'center')
			]),
		_List_fromArray(
			[
				A2(
				elm$html$Html$div,
				_List_fromArray(
					[
						A2(elm$html$Html$Attributes$style, 'display', 'flex'),
						A2(elm$html$Html$Attributes$style, 'margin-bottom', '18px')
					]),
				_List_fromArray(
					[
						A2(
						elm$core$Basics$composeR,
						elm$core$Tuple$first,
						author$project$Bottle$viewPill(
							elm$core$Maybe$Just(3)))(bottle.L),
						A2(
						elm$core$Basics$composeR,
						elm$core$Tuple$second,
						author$project$Bottle$viewPill(
							elm$core$Maybe$Just(2)))(bottle.L)
					])),
				author$project$Bottle$view(bottle)
			]));
};
var elm$html$Html$span = _VirtualDom_node('span');
var author$project$TwoPlayer$Game$view = function (model) {
	switch (model.$) {
		case 0:
			return A2(
				elm$html$Html$div,
				_List_Nil,
				_List_fromArray(
					[
						elm$html$Html$text('💊💊💊')
					]));
		case 1:
			return A2(
				elm$html$Html$div,
				_List_Nil,
				_List_fromArray(
					[
						elm$html$Html$text('💊💊💊')
					]));
		case 2:
			var state = model.a;
			return A2(
				elm$html$Html$div,
				_List_Nil,
				_List_fromArray(
					[
						A2(
						elm$html$Html$div,
						_List_fromArray(
							[
								A2(elm$html$Html$Attributes$style, 'display', 'flex'),
								A2(elm$html$Html$Attributes$style, 'flex-direction', 'row')
							]),
						_List_fromArray(
							[
								author$project$TwoPlayer$Game$viewPlayer(state.g),
								A2(
								elm$html$Html$div,
								_List_fromArray(
									[
										A2(elm$html$Html$Attributes$style, 'margin', '0 12px')
									]),
								_List_fromArray(
									[
										A2(
										elm$html$Html$h3,
										_List_Nil,
										_List_fromArray(
											[
												elm$html$Html$text('level')
											])),
										A2(
										author$project$TwoPlayer$Game$spaceBetween,
										_List_Nil,
										_List_fromArray(
											[
												A2(
												elm$html$Html$span,
												_List_Nil,
												_List_fromArray(
													[
														A2(elm$core$Basics$composeR, elm$core$String$fromInt, elm$html$Html$text)(state.g.U)
													])),
												A2(
												elm$html$Html$span,
												_List_Nil,
												_List_fromArray(
													[
														A2(elm$core$Basics$composeR, elm$core$String$fromInt, elm$html$Html$text)(state.e.U)
													]))
											])),
										A2(
										elm$html$Html$h3,
										_List_Nil,
										_List_fromArray(
											[
												elm$html$Html$text('speed')
											])),
										A2(
										author$project$TwoPlayer$Game$spaceBetween,
										_List_Nil,
										_List_fromArray(
											[
												A2(
												elm$html$Html$span,
												_List_Nil,
												_List_fromArray(
													[
														A2(elm$core$Basics$composeR, author$project$Bottle$speedToString, elm$html$Html$text)(state.g.aa)
													])),
												A2(
												elm$html$Html$span,
												_List_Nil,
												_List_fromArray(
													[
														A2(elm$core$Basics$composeR, author$project$Bottle$speedToString, elm$html$Html$text)(state.e.aa)
													]))
											])),
										A2(
										elm$html$Html$h3,
										_List_Nil,
										_List_fromArray(
											[
												elm$html$Html$text('virus')
											])),
										A2(
										author$project$TwoPlayer$Game$spaceBetween,
										_List_Nil,
										_List_fromArray(
											[
												A2(
												elm$html$Html$span,
												_List_Nil,
												_List_fromArray(
													[
														elm$html$Html$text(
														author$project$TwoPlayer$Game$displayViruses(state.g))
													])),
												A2(
												elm$html$Html$span,
												_List_Nil,
												_List_fromArray(
													[
														elm$html$Html$text(
														author$project$TwoPlayer$Game$displayViruses(state.e))
													]))
											]))
									])),
								author$project$TwoPlayer$Game$viewPlayer(state.e)
							]))
					]));
		case 3:
			var state = model.a;
			return A2(
				elm$html$Html$div,
				_List_Nil,
				_List_fromArray(
					[
						A2(
						author$project$TwoPlayer$Game$viewMessage,
						'Paused',
						A2(
							elm$html$Html$button,
							_List_fromArray(
								[
									elm$html$Html$Events$onClick(author$project$TwoPlayer$Game$Resume)
								]),
							_List_fromArray(
								[
									elm$html$Html$text('resume')
								])))
					]));
		default:
			var state = model.a;
			return A2(
				elm$html$Html$div,
				_List_Nil,
				_List_fromArray(
					[
						A2(
						author$project$TwoPlayer$Game$viewMessage,
						function () {
							var _n1 = state.ad;
							if (!_n1) {
								return '1p wins';
							} else {
								return '2p wins';
							}
						}(),
						A2(
							elm$html$Html$div,
							_List_Nil,
							_List_fromArray(
								[
									A2(
									elm$html$Html$button,
									_List_fromArray(
										[
											elm$html$Html$Events$onClick(author$project$TwoPlayer$Game$Reset)
										]),
									_List_fromArray(
										[
											elm$html$Html$text('Main Menu')
										]))
								]))),
						author$project$TwoPlayer$Game$view(
						author$project$TwoPlayer$Game$Playing(state.A))
					]));
	}
};
var author$project$TwoPlayer$view = function (model) {
	if (!model.$) {
		var state = model.a;
		return author$project$OnePlayer$Menu$view(state);
	} else {
		var state = model.a;
		return A2(
			elm$html$Html$map,
			author$project$TwoPlayer$GameMsg,
			author$project$TwoPlayer$Game$view(state));
	}
};
var elm$html$Html$h1 = _VirtualDom_node('h1');
var author$project$Main$view = function (model) {
	return A2(
		elm$html$Html$div,
		_List_fromArray(
			[
				A2(elm$html$Html$Attributes$style, 'display', 'flex'),
				A2(elm$html$Html$Attributes$style, 'flex-direction', 'column'),
				A2(elm$html$Html$Attributes$style, 'align-items', 'center')
			]),
		_List_fromArray(
			[
				A2(
				elm$html$Html$h1,
				_List_Nil,
				_List_fromArray(
					[
						elm$html$Html$text('dr. mario 💊')
					])),
				function () {
				switch (model.$) {
					case 0:
						return author$project$Main$viewSelecting;
					case 1:
						var state = model.a;
						return A2(
							elm$html$Html$map,
							author$project$Main$OneMsg,
							author$project$OnePlayer$view(state));
					default:
						var state = model.a;
						return A2(
							elm$html$Html$map,
							author$project$Main$TwoMsg,
							author$project$TwoPlayer$view(state));
				}
			}()
			]));
};
var elm$browser$Browser$element = _Browser_element;
var author$project$Main$main = elm$browser$Browser$element(
	{
		aO: function (_n0) {
			return _Utils_Tuple2(author$project$Main$Selecting, elm$core$Platform$Cmd$none);
		},
		aX: author$project$Main$subscriptions,
		aZ: author$project$Main$update,
		a$: author$project$Main$view
	});
_Platform_export({'Main':{'init':author$project$Main$main(
	elm$json$Json$Decode$succeed(0))(0)}});}(this));