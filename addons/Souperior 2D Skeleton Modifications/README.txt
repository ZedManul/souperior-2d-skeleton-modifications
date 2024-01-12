Thanks for downloading my plugin :]

/!\THIS README IS OUTDATED. A NEW, UP TO DATE README WILL BE ADDED NEXT COMMIT. /!\

This has been reworked a bit since last time;
The modification stack is now a separate node.
I recommend putting it as a direct child of the Skeleton2D node.
Technically, it doesnt really matter where exactly it is in the tree, 
as you can just manually select the skeleton node for it to affect.
By default it will try to find a skeleton somewhere above itself in the hierarchy.


Modifications (IK, LookAt, SubStack)
MUST be children (direct or not) of the Stack node.
If a modification is a direct child of a substack 
(BUT NOT OF ANOTHER MODIFICATION), 
it will also inherit the enable state of the substacj

Skeletons are, alas, still a bit buggy, and weird edgecases arise when shifting nodes around.
If something seems to be broken, try reloading your project.
Skeletons are weird like that.

There is now support for custom easing motion on all constraints!
I am quite happy with how the system turned out, 
and I will likely make it a separate plugin later on.

Soupy Nodes are entirely separate from the inbuilt skeleton modifications, 
and applying both at the same time to one bone may be a bad idea.

The system also relies on bone angle and length, so make sure to
disable "auto calculate" on bones that dont have any further child bones.

Additionally, I have provided a demo scene 
that can help you get a grasp on the intended usage of the addon.


I am not sure if I will be adding more to this plugin in the future.
In the meantime, check out "Wiggly Appendage 2D" by Tameno-01 for jiggle bone implementation.
