---
layout: post
title: Using D3.js with Angular.js
date: 30 Dec 2012
location: Washington, DC
tags:
- AngularJS
- D3.js
- Technology
summary: In this post I will reproduce one of the examples from <em>Interactive Data Visualization for the Web</em> using D3.js with the Angular.js framework.
---


I recently picked up a copy of *Interactive Data Visualization for the Web* [(link)](http://shop.oreilly.com/product/0636920026938.do) by [Scott Murray](http://alignedleft.com) to learn a bit about how to use <a href="http://d3js.org/" target="_blank">D3.js</a>.  About the same time I started messing around with both <a href="http://angularjs.org/" target="_blank">Angular</a> and Coffeescript.  In this post, I'll show you how to reproduce one of the examples in the book using D3, Angular, and Coffeescript together.

Here's where <a href="http://examples.1000monkeys.co/d3-angular-bars/#/" target="_blank">we are going</a> -- a bar chart that updates with a new random value every time you click.  Although basic, this example demonstrates some of the important features of D3 and Angular:

<ul>
    <li>how to bind data to elements</li>
    <li>selecting elements that are entering, exiting, or updating in the chart</li>
    <li>using transitions to generate nice looking updates</li>
    <li>implementing custom directives and two-way data-binding in Angular to create a chart that auto-updates when the data changes</li>
</ul>

I'll assume you have some working knowledge of D3 and Coffeescript and are more interested in how to get it to work within Angular.  The code for this example is [hosted on Github](https://github.com/BTBurke/d3-angular-example).

Setting up Angular routes and our data model
--------------------------------------------

To start, let's set up Angular with a route, controller, and template for the view that contains our chart.

<script src="https://gist.github.com/4423723.js"></script>

In App.coffee, we start by defining our app as <code>d3testApp</code> and declare dependencies <code>d3testApp.controllers</code> and <code>d3testApp.directives</code>.  We then configure a route to render a template and bind it to our data model in the controller <code>MainCtrl</code>.

In our controller <code>Main.coffee</code> we set up our data model and methods.  

<script src="https://gist.github.com/4423773.js"></script>

Our data model is defined in <code>$scope.data</code> and consists of a list of hashes, each with a <code>time</code> and <code>data</code> field.  In D3, we will render the data components as the height of the bar and use the time as a key value that will help to properly bind our data to elements over successive updates.  The function <code>$scope.updateData</code> pushes a new random datapoint onto the array up to a maximum of <code>$scope.dataLength</code> elements.

Using Angular directives to render and update the graph
-------------------------------------------------------
Here's where the start of the magic happens.  We'll set up a directive to bind data changes to a function that will update the graph.  In <code>Directives.coffee</code> we'll create a directive called <code>scVisualization</code>.

<script src="https://gist.github.com/4423800.js"></script>

Let's step through this in detail.  We declare an angular module named <code>d3testApp.directives</code>.  The directive is named <code>scVisualization</code>.  The return statement sets up the data-binding that we want and declares the actions we want the directive to take when changes happen.

The first, <code>restrict: E</code> restricts this directive to use as a tag in the document markup, rather than as an attribute somewhere else.  <code>scope: { val: '=' }</code> sets up a two-way data-binding between our controller and this directive.  We define the binding in our view by using this new directive and setting up a relationship between `val` and the `data` property in our controller.  The `link` statement declares the function to be evaluated when the bound data changes.  

In this callback, we first call a helper function that will append an SVG element when the page renders with the first data point.  We then set up a <code>$watch</code> on <code>val</code>.  The second argument is a function <code>updateGraph</code> that is called with the old and new values of <code>val</code> any time the data changes.  The last argument, set to `true`, is very important for the way our data model is implemented.  By default, $watch only evaluates <code>updateGraph</code> on changes to the object reference indicated by <code>val</code>.  Setting the third argument to true ensures that we do an object comparison between the old and new values of <code>val</code> which will fire the graph update any time we push a new value onto the array.

Now, let's look at the <code>createSVG</code> and <code>updateGraph</code> functions.

<script src="https://gist.github.com/4423814.js"></script>

In <code>createSVG</code> I check for the existence of a <code>svg</code> on the scope.  If not, I create an SVG element and bind it to the scope.  Important variables like width and height are also properties of the scope so that they can be easily passed to the <code>updateGraph</code> call.

Why do we put these properties on the scope?  Angular's $watch calls <code>updateGraph</code> with only three arguments: newVal, oldVal, and scope.  We separate the two functions so that we can pass the <code>element</code> reference to add the SVG to the DOM in the proper location.  Afterwards, the SVG element persists on the scope and we will use it to grab references to the RECT elements in <code>updateGraph</code>.

Here's <code>updateGraph</code>:

<script src="https://gist.github.com/4423820.js"></script>  

I won't go through this in detail, but let me point out a few important things.  Updating elements in this type of chart follows a D3 design pattern:

<ol>
    <li>Bind your data to the SVG elements, in this case a bunch of RECTs, using <code>svg.selectAll("rect").data(...)</code>.</li>
    <li>Since we are pushing new data one point at a time, we also specify a key function when we bind our data using <code>.data(newVal, (d) -> d.time)</code>.  This keeps the data bound to the appropriate SVG element as elements enter and exit the chart.</li>
    <li>Update the existing elements using a transition, in this case <code>bars.transition()</code>.</li>
    <li>Create new SVG elements for data that is entering the chart, here using <code>bars.enter()</code>.  You can add transition effects, delay, etc.</li>
    <li>Select and remove elements that are leaving the chart with <code>bars.exit().remove()</code>.</li>
    <li>Finally, we apply the attributes to all the elements to start the transition and move them to the updated location.</li>
</ol>

To glue it all together, let's take a look at <code>main.html</code> the view that will bind our data, graph updates, and handle user interaction to create new random data points.

<script src="https://gist.github.com/4423894.js"></script>

This one is pretty simple.  We create an element, in this case a link and bind it via an Angular click event to our function <code>updateData</code>.  This will add a new random data point on each user click.  The directive is called using the element <code>sc-Visualization</code>.  The binding between our data and the directive is accomplished by linking <code>val="data"</code>.

That's it.  If you have any improvements, please leave me a note in the comments.  And if you've read this far and find it useful, <a href="http://twitter.com/bryanburke">follow me on twitter</a> for future posts.
