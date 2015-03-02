
@interface ArtistsTableViewController : UITableViewController
<UITableViewDataSource, UITableViewDelegate>

// A mutable array of Artist objects, to be displayed by the table view.
@property (nonatomic, strong) NSMutableArray *artists;

@end

