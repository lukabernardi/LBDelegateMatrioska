LBDelegateMatrioska
====

This class is a subclass of `NSProxy` subclass that allows you to have multiple delegate helper objects (instead of the usual 1 to 1 relationship between the delegator and delegate).

## Usage

You can init an `LBDelegateMatrioska` object with as many delegate objects you want

```
LBDelegateMatrioska *matrioska = [[LBDelegateMatrioska alloc] initWithDelegates:@[mapClusterDelegate, self]];
```

and the add this object as delegate

```
mapView.delegate = matrioska
```

In this way every time the MKMapView calls a delegate this call is forwarded to all the delegates respecting the array sorting (if you like the matrioska metaphor the `mapClusterDelegate` is the outer layer and is the first one called and then `self`)

The proxy object keep a **weak** reference to all the delegate objects, therefore is your responsibility to keep the objects alive with a strong reference. Anyway, by using an `NSPointerArray` I'm sure that if a delegate gets deallocated the reference inside the array is nil-ed and therefor doesn't crash the app.

There are just 2 basic rule and one limitation you have to keep in mind:

- The proxy will respond `YES` to the `respondToSelector:` message if and only if at least one of the provided delegate objects respond `YES` to the same method.
- The previous rule apply the same for `conformsToProtocol:`
- If the delegate method is non-`void` returning method only the first delegate (that is able to respond to that method) is called and its return value is returned.

## Why? / Use Case
I start develop this class because I was tasked to implement annotation clustering in `MKMapView`.
 
I found different libraries around the web but I wasn't really satisfied with the implementations: a lot of them subclass or swizzle method in `MKMapView` in order to hookup on the `-mapView:regionWillChangeAnimated:`/ `-mapView:regionDidChangeAnimated:` methods call.

So, the point is that I don't want to mess with delegator but I want to hook inside one of his delegate method call, **and** I want to still be able to receive all the delegate call (back to the map example: I still want that the ViewController that own MKMapView to be able to receive all the delegate call).

I found really interesting the ability to inject sort-of-plugin inside the delegate that split the responsibility of handling the delegate work. Again with my map example: I can easily "plug-in" the cluster behavior in any MKMapView (and eventually other behaviors to enhance the map view)

## Unit Test

The class comes with a unit test coverage (using [Kiwi](https://github.com/allending/Kiwi)). In order to have Kiwi and run the test you may want to run `pod install` and open the workspace (instead of the project file).

## License

LBDelegateMatrioska is available under the MIT license. See the LICENSE file for more info.