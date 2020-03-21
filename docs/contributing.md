# Contributing

# Основное

* Старайтесь максимально разбивать большие изменения на пачку маленьких и/или вносите их поэтапно. Чем больше пулл реквест - тем сложнее и дольше его проверять.
* Мы ожидаем, что вы поможете нам поддерживать код, который вы добавили. Скорее всего мы к вам обратимся в случае возникновения каких-то проблем, связанных с вашими изменениями, в том числе рантаймами или багами.
* Помимо разбиения кода по пулл реквестам - код так же стоит разбивать по модулям. Если вы добавляете какую-то новую логику, серьезно подумайте над тем, чтобы положить ее в отдельный, собственный файл, если нет каких-то то явных причин добавить его в существующий.
* Ваши изменения не должны содержать закомментированный код. В комментариях вместо того, чтобы объяснять ЧТО делает ваш код, пишите ЗАЧЕМ он это делает, если это необходимо.
* Пулл реквесты не должны содержать изменений, которые не относятся к функциональности, указанной в описании самого пулл реквеста и коммитов.
* Если пулл реквест вносит изменения касающиеся существующего Github иссуя - это должно быть указано в описаниях пулл реквеста и коммита. Например, "Fix broken floor sprites, close #23" (подробнее: https://help.github.com/articles/closing-issues-via-commit-messages).

# Code conventions

### Используйте абсолютные пути

DM позволяет писать код блоками:

```DM
datum
	datum1
		var
			varname1 = 1
			varname2
			static
				varname3
				varname4
		proc
			proc1()
				code
			proc2()
				code

		datum2
			varname1 = 0
			proc
				proc3()
					code
			proc2()
				..()
				code
```

Такой способ написания делает невозможным текстовый поиск функции или типа по коду. Единственное исключение - внутри блока описания типа можно определять переменные.

Тот же код, написанный правильно:

```DM
/datum/datum1
	var/varname1
	var/varname2
	var/static/varname3
	var/static/varname4

/datum/datum1/proc/proc1()
	code
/datum/datum1/proc/proc2()
	code
/datum/datum1/datum2
	varname1 = 0
/datum/datum1/datum2/proc/proc3()
	code
/datum/datum1/datum2/proc2()
	..()
	code
```

### Не избавляйтесь от проверки типов
Запрещено использовать оператор `:`. Всегда явно преобразуйте переменную к конкретному типу.

### Пути типов всегда должны начинаться с /
Например: `/datum/thing`, вместо `datum/thing`

### Пути типов всегда должны быть в нижнем регистре
Например: `/datum/thing/blue`, вместо `datum/thing/BLUE` или `datum/thing/Blue`

### Явно определяйте переменные в формате var/name
DM позволяет определять переменные и другими способами, но всегда явно пишите `var` в целях консистентности. В том числе, это касается аргументов функций.

### Табы, а не пробелы.
Для интендации кода используйте табы!

(Вы можете использовать пробелы для выравнивания, но всегда сначала вставляйте отступ табами, а уже потом добавляйте пробелы в конце)

### Избегайте дублирования кода
Когда вы копируете один и тот же код в разные места - появляется необходимость одинаково поддерживать этот код в двух местах. При любом изменении оригинального кода надо помнить о копии этого кода в другом месте и зачастую вносить изменения и туда.

Чтобы избежать подобных проблем используйте наследование объектов друг от друга или же просто вынесите необходимую логику в отдельную функцию.

### Предпочитайте `Initialize()` вместо `New()` для atom.
Контроллеры, используемые в нашей сборке, должны справляться с длительными операциями и лагами, но они не могут контролировать то, что происходит во время загрузки карты, когда для всех объектов вызывается New. Для любых новых объектов, без явной необходимости, используйте `Initialize`, чтобы сделать все, что вы хотели сделать в `New`. Это уменьшает количество функций вызываемых на этапе загрузки карты. Чтобы узнать больше про то, как работает `Initialize`, смотрите https://github.com/ChaoticOnyx/OnyxBay/blob/dev/code/game/atoms.dm

### Не используйте магические значения
Это касается различных переменных "mode", которые могут быть 1 или 2, но при этом неясно, что конкретно они означают. Используйте #define, чтобы явно указать, что означает то или иное значение. Например:

````DM
/datum/proc/do_the_thing(thing_to_do)
	switch(thing_to_do)
		if(1)
			(...)
		if(2)
			(...)
````
Здесь неясно, что означают "1" и "2"! Вместо этого можно было бы написать:
````DM
#define DO_THE_THING_REALLY_HARD 1
#define DO_THE_THING_EFFICIENTLY 2
/datum/proc/do_the_thing(thing_to_do)
	switch(thing_to_do)
		if(DO_THE_THING_REALLY_HARD)
			(...)
		if(DO_THE_THING_EFFICIENTLY)
			(...)
````
Так получается гораздо понятнее, что увеличивает читаемость вашего кода.

### Операторы контроля выполнения
(if, while, for и другие)

* Все операторы контроля выполнения не должны содержать другого кода на той же строчке (`if (blah) return`)
* Все операторы контроля выполнения, сравнивающие переменную с каким-то значением, должны использовать формулу `переменная` `оператор` `значение`, не наоборот (например: `if (count <= 10)`, вместо `if (10 >= count)`)

### Используйте ранний return
Не стоит строчить многоуровневые конструкции из блоков if, когда того же результата можно достичь ранним возвратом из функции

Вот так делать не стоит:
````DM
/datum/datum1/proc/proc1()
	if (thing1)
		if (!thing2)
			if (thing3 == 30)
				do stuff
````
А так уже лучше:
````DM
/datum/datum1/proc/proc1()
	if (!thing1)
		return
	if (thing2)
		return
	if (thing3 != 30)
		return
	do stuff
````

### Разработка безопасного кода
* Всегда относитель к пользовательскому вводу так, как будто он намеренно пытается все сломать. Проверяйте пользовательский ввод на все случаи, которые не соответсвуют ожиданиям вашего кода. Для чисел проверяйте границы, для строк используйте escape-функции.
* Обязательно эскейптьте все команды к базе данных - используйте sanitizeSQL чтобы обработать весь текст от игроков и админов перед тем как передавать его в базу данных. Для чисел используйте isnum().
* Все вызовы топиков обязательно нужно проверять на их корректность. Такие вызовы могут быть подделаны со стороны клиента, поэтому их содержимым может быть что угодно!
* Скрывайте от игроков любую информацию, которая может быть использована для метагейма (даже такую простую, как количество игроков, которые нажали Declare, так как даже она может быть использована, чтобы вычислить текущий режим).
* Когда вы пишите код, который может каким-то образом влиять на раунд и генерировать *ВЕСЕЛЬЕ*, дважды проверьте, что такой функционал будет доступен только админам соответствующего ранга.

### Файлы
* Рантаймы не содержат полного пути до файла - поэтому избегайте одинаковых названий файлов даже в разных папках.
* Названия файлов не должны содержать пробелов или символов, которые придется эскейпить, указывая uri.
* Названия файлов и все пути всегда должны быть в нижнем регистре, чтобы избежать проблем, связанных с разным отношением к регистру в разных операционных системах.

### Operators
#### Spacing
(this is not strictly enforced, but more a guideline for readability's sake)

* Operators that should be separated by spaces
	* Boolean and logic operators like &&, || <, >, ==, etc (but not !)
	* Bitwise AND &
	* Argument separator operators like , (and ; when used in a forloop)
	* Assignment operators like = or += or the like
* Operators that should not be separated by spaces
	* Bitwise OR |
	* Access operators like . and :
	* Parentheses ()
	* logical not !

Math operators like +, -, /, *, etc are up in the air, just choose which version looks more readable.

#### Use
* Bitwise AND - '&'
	* Should be written as ```bitfield & bitflag``` NEVER ```bitflag & bitfield```, both are valid, but the latter is confusing and nonstandard.
* Associated lists declarations must have their key value quoted if it's a string
	* WRONG: list(a = "b")
	* RIGHT: list("a" = "b")

### Dream Maker Quirks/Tricks
Like all languages, Dream Maker has its quirks, some of them are beneficial to us, like these

#### In-To for-loops
```for(var/i = 1, i <= some_value, i++)``` is a fairly standard way to write an incremental for loop in most languages (especially those in the C family), but DM's ```for(var/i in 1 to some_value)``` syntax is oddly faster than its implementation of the former syntax; where possible, it's advised to use DM's syntax. (Note, the ```to``` keyword is inclusive, so it automatically defaults to replacing ```<=```; if you want ```<``` then you should write it as ```1 to some_value-1```).

HOWEVER, if either ```some_value``` or ```i``` changes within the body of the for (underneath the ```for(...)``` header) or if you are looping over a list AND changing the length of the list then you can NOT use this type of for-loop!

### for(var/A in list) VS for(var/i in 1 to list.len)
The former is faster than the latter, as shown by the following profile results:
https://file.house/zy7H.png
Code used for the test in a readable format:
https://pastebin.com/w50uERkG


#### Istypeless for loops
A name for a differing syntax for writing for-each style loops in DM. It's NOT DM's standard syntax, hence why this is considered a quirk. Take a look at this:
```DM
var/list/bag_of_items = list(sword, apple, coinpouch, sword, sword)
var/obj/item/sword/best_sword
for(var/obj/item/sword/S in bag_of_items)
	if(!best_sword || S.damage > best_sword.damage)
		best_sword = S
```
The above is a simple proc for checking all swords in a container and returning the one with the highest damage, and it uses DM's standard syntax for a for-loop by specifying a type in the variable of the for's header that DM interprets as a type to filter by. It performs this filter using ```istype()``` (or some internal-magic similar to ```istype()``` - this is BYOND, after all). This is fine in its current state for ```bag_of_items```, but if ```bag_of_items``` contained ONLY swords, or only SUBTYPES of swords, then the above is inefficient. For example:
```DM
var/list/bag_of_swords = list(sword, sword, sword, sword)
var/obj/item/sword/best_sword
for(var/obj/item/sword/S in bag_of_swords)
	if(!best_sword || S.damage > best_sword.damage)
		best_sword = S
```
specifies a type for DM to filter by.

With the previous example that's perfectly fine, we only want swords, but here the bag only contains swords? Is DM still going to try to filter because we gave it a type to filter by? YES, and here comes the inefficiency. Wherever a list (or other container, such as an atom (in which case you're technically accessing their special contents list, but that's irrelevant)) contains datums of the same datatype or subtypes of the datatype you require for your loop's body,
you can circumvent DM's filtering and automatic ```istype()``` checks by writing the loop as such:
```DM
var/list/bag_of_swords = list(sword, sword, sword, sword)
var/obj/item/sword/best_sword
for(var/s in bag_of_swords)
	var/obj/item/sword/S = s
	if(!best_sword || S.damage > best_sword.damage)
		best_sword = S
```
Of course, if the list contains data of a mixed type then the above optimisation is DANGEROUS, as it will blindly typecast all data in the list as the specified type, even if it isn't really that type, causing runtime errors.

#### Dot variable
Like other languages in the C family, DM has a ```.``` or "Dot" operator, used for accessing variables/members/functions of an object instance.
eg:
```DM
var/mob/living/carbon/human/H = YOU_THE_READER
H.gib()
```
However, DM also has a dot variable, accessed just as ```.``` on its own, defaulting to a value of null. Now, what's special about the dot operator is that it is automatically returned (as in the ```return``` statement) at the end of a proc, provided the proc does not already manually return (```return count``` for example.) Why is this special?

With ```.``` being everpresent in every proc, can we use it as a temporary variable? Of course we can! However, the ```.``` operator cannot replace a typecasted variable - it can hold data any other var in DM can, it just can't be accessed as one, although the ```.``` operator is compatible with a few operators that look weird but work perfectly fine, such as: ```.++``` for incrementing ```.'s``` value, or ```.[1]``` for accessing the first element of ```.```, provided that it's a list.

## Globals versus static

DM has a var keyword, called global. This var keyword is for vars inside of types. For instance:

```DM
mob
	var
		global
			thing = TRUE
```
This does NOT mean that you can access it everywhere like a global var. Instead, it means that that var will only exist once for all instances of its type, in this case that var will only exist once for all mobs - it's shared across everything in its type. (Much more like the keyword `static` in other languages like PHP/C++/C#/Java)

Isn't that confusing?

There is also an undocumented keyword called `static` that has the same behaviour as global but more correctly describes BYOND's behaviour. Therefore, we always use static instead of global where we need it, as it reduces suprise when reading BYOND code.
