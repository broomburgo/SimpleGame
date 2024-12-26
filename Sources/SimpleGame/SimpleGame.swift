import Narratore
import SimpleHandler
import SimpleSetting
import SimpleStory

@main
enum Main {
  static func main() async {
    let handler = SimpleHandler<SimpleStory>.init()

    let runner = Runner<SimpleStory>.init(
      handler: handler,
      status: handler.askToRestoreStatusIfPossible() ?? .init(
        world: .init(),
        scene: SimpleStory.initialScene()
      )
    )

    await runner.start()
  }
}
