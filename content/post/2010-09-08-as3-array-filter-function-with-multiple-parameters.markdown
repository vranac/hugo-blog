---
date: 2010-09-08 19:34:11+00:00
slug: as3-array-filter-function-with-multiple-parameters
title: AS3 Array filter function with multiple parameters
categories:
- Actionscript
- AS3
- Flash
tags:
- Actionscript
- AS3
- Flash
comments: false
draft: false
---





Recently I have been working on a pure AS3 project that at one point required me to do quite a lot of filtering on a few arrays.
While AS3 provides a nice new set of functions for filtering, they all had a common shortcoming for my usage scenario, they can not accept parameters directly.
<!--more-->



Let's say that I need to filter an array acording to value range, not a problem with filter function:



{{< codecaption lang="actionscript" >}}

private function filterAnswersByAgeInTwenties(element:*, index:int, arr:Array):Boolean {
    return element.age >= 20 && element.age < 30;
}

var result:Array = _answers.filter(filterAnswersByAgeInTwenties);

{{< /codecaption >}}



Nice and simple isn't it.




Now what to do if I need to have more ranges, for example, people in thirties and fourties, this quickly becomes unruly mess of single use functions and a whole lot of copy/paste error prone code.



{{< codecaption lang="actionscript" >}}

private function filterAnswersByAgeInTwenties(element:*, index:int, arr:Array):Boolean {
    return element.age >= 20 && element.age < 30;
}

private function filterAnswersByAgeInThirties(element:*, index:int, arr:Array):Boolean {
    return element.age >= 30 && element.age < 40;
}

private function filterAnswersByAgeInFourties(element:*, index:int, arr:Array):Boolean {
    return element.age >= 40 && element.age < 50;
}

var resultTwenties:Array = _answers.filter(filterAnswersByAgeInTwenties);
var resultThirties:Array = _answers.filter(filterAnswersByAgeInThirties);
var resultFoourties:Array = _answers.filter(filterAnswersByAgeInFourties);


{{< /codecaption >}}



Ugly isn't it.






Fortunately there is a better way. If you pass an object to the filter function, the function will execute in the scope of that object, and you will be able to access it's parameters.



{{< codecaption lang="actionscript" >}}

private function filterAnswersByAgeGroup(from:int, to:int):Array {
    var obj:Object = new Object();
    obj.from = from;
    obj.to = to;

    var filterFunction:Function = function(element:*, index:int, arr:Array):Boolean {
        return element.age >= this.from && element.age < this.to;
    }

    return _answers.filter(filterFunction, obj);
}

var resultTwenties:Array = filterAnswersByAgeGroup(20, 30);
var resultThirties:Array = filterAnswersByAgeGroup(30, 40);
var resultFoourties:Array = filterAnswersByAgeGroup(40, 50);


{{< /codecaption >}}



This looks so much better, doesn't it?




Less code, more reuseable, easier to maintain.
