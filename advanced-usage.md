# Advanced Usage

Until now, the majority of this documentation has focused on the primary out-of-the-box functionality of Rails remote forms, which are just like 1996 forms except they are submitted using 1999's XMLHttpRequest object. This page deals with contemporary interfaces, tilting towards the future.

Generally speaking, traditional forms are a way to submit a bucket of associated key/value pairs intended to update a single instance of a resource. With the advent of JS-powered interfaces, there are now many patterns which require re-thinking how to update individual attributes while ensuring a consistent state between the client and server. Unfortunately, the aging HTML form is poorly equipped to deal with anything that doesn't conform to a dated, white bread possibility space.

Optimism is a server-side solution. It would be impractical to try and provide client-side solutions to these problems; even if we succeed in covering every framework and design approach, we don't want to limit creative freedom or made integration difficult just because we didn't anticipate something.

That said, we believe Optimism provides a lot of flexibility for people who can build or adapt their client-side solutions to work with our simple API; in many cases, it just comes down to sending less data. When combined with other tools, comprehensive solutions are possible with very little custom code.

## Reactive validations

Whether hotter/colder updates about the availability of our desired username or having the background color of a text input change color when we type too many characters, people have come to expect real-time feedback from input elements. If you have to submit a form to find out that your password needs to have special characters in it, well, that page sucks and many users are sophisticated enough to feel legitimate frustration when developers get this wrong.

The key to real-time validation updates with Rails remote forms is that you can submit to the same resource end-point with the same form structure, just constrained to only the current attribute. That means your client code has to be able to pick up the current form's HTTP **\_method** and **authenticity\_token** fields and pack them into a POST along with the desired attribute, making sure to grab the full Rails name key for the attribute. This is especially vital when dealing with nested forms, for example Comments embedded in a Post might look like '**post\[comments\_attributes\]\[0\]\[body\]**'. You'll also need to remember to **set the X-Requested-With header to 'XMLHttpRequest'**.

In theory, if you follow the thread of the previous paragraph Optimism should "just work" because the post\_params will only have the attribute currently being modified in it. However, if your application works differently, the most important thing to remember is that the 2nd parameter to the [broadcast\_errors](https://optimism.leastbad.com/reference#broadcast_errors-model-attributes) function can also be a single String or Symbol. This means that you can use Optimism regardless of whether there's a form on the active page, even if it doesn't look like a form. You could give live feedback for a typeahead search in a header that uses an input element outside of the context of a form.

Optimism works by looking for elements with IDs that match expected patterns. If you're only emitting events then even that constraint is off the table. Advanced users can think of Optimism as a message bus for communicating validation errors in real-time over websockets, which is very liberating.

![](.gitbook/assets/success_factors.svg)

## In-line edit UIs

After the advances in UI design by thinkers such as Larry Tesler and Jef Raskin during the 1980s led to concepts like [modeless computing](https://en.wikipedia.org/wiki/Mode_%28user_interface%29), it could be argued that the humble HTML form was a primitive modeless concept designed to work over a stateless protocol.

Then REST API came along and brought the computing world right back to the 1970s, with distinct modes for listing, viewing and editing data. REST brought much needed structure, a discoverable interface and good URL conventions. It is also fundamentally inflexible and has little provision for real-time dynamic interfaces, much less bi-directional data binding. That leaves us developers to figure out how to find a general solution to editing data without leaving the view \(show\) state.

Unlike reactive validations, where the server is a single source of truth, actually changing a single data value from an arbitrary place in your application is a surprisingly difficult challenge, before even considering all of the different client libraries and design approaches one might take.

Someone tackling an in-line edit interface in Rails need to tackle two problems: syncronization and partial updates.

Syncronization is the easiest to explain and the hardest to solve. Simply: what if the value of data changes on the server after the page has been rendered on client browser? Libraries like [StimulusReflex](https://github.com/hopsoft/stimulus_reflex) go to great pains to not replace the contents of an input element while you're typing into it. Simply put, there's an opinionated decision made that what you're typing should be the source of truth until that element no longer has focus. You then have to figure out how to decide which value wins: the one on the server that the user never saw, or this new input from the user? There is no right answer, and usually the last update wins. Interfaces such as Optimism and libraries like StimulusReflex give us the opportunity to consider a hybrid approach where the form could update to show that data has changed on the server, either showing the new server value alongside the input element, or even locking the input element entirely.

Partial updates is an umbrella concept for a group of related concerns that emerge when updating a subset of attributes on a model that has rules in place covering many attributes. Some of those attributes might not be included in the subset you're updating. For example, if you're trying to provide an in-line edit UI for a model that has multiple required attributes, when you enter data for the first attribute the model will not be created because it fails validations. This raises the question of where those individual updates go before you have enough data captured to create a valid instance of the model. Rails does not address this gracefully out of the box, beyond implying that a new model instance should be created in one shot while some additional flexibility is possible with updates.

It's impossible to be half-pregnant. In Rails, it's impossible to half-save a new record.

For example, this means that it's really tricky to implement a git-style commit concept, where you might make multiple changes to a dataset before ultimately commiting it to a permanent datastore. This was less practical in the era of stateless HTTP page reloads, but now that we have websockets and powerful UI libraries, it sucks that we don't have better answers to these patterns.

Another casualty is the prospect of undo/redo capable UIs. Today, undo/redo is generally confined to text editing operations, while applications like Photoshop have had powerful history navigators for decades. Frankly, it's upsetting that so much energy goes into making React useful when we still haven't solved making undo work across multiple components on a single page.

Partial updates aren't a Rails-specific problem, but Rails validation infrastucture does make this design goal harder to achieve. All general schemes have constraints and limitations, and if DHH had made different decisions, we would have different problems to deal with.

There is also progress in the ActiveRecord API. You can now query individual attributes to see if they are valid or dirty \(changed\). These building blocks offer paths to more comprehensive solutions in the future.

What Optimism can offer today is a bridge while other aspects of this domain are figured out for the next generation of web developers. It has the ability to add a CSS class representing invalid state to the form. It can even be [configured](https://optimism.leastbad.com/reference#initializer) to disable the Submit button if the model is in an invalid state. While not a complete solution, we hope this proves a useful piece of the picture.

![](.gitbook/assets/super_woman.svg)

## 

