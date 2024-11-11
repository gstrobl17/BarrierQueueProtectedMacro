import BarrierQueueProtected
import Foundation

struct Test {
    
    @BarrierQueueProtected
    var aVeryMerryXmas: String?

    @BarrierQueueProtected
    var value: Int

}
