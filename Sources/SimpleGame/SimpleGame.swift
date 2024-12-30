import Narratore
import SimpleHandler
import SimpleSetting
import SimpleStory

@main
enum Main {
  static func main() async {
    let handler = SimpleHandler<SimpleStory>()

    let runner = Runner<SimpleStory>(
      handler: handler,
      status: handler.askToRestoreStatusIfPossible() ?? .init(
        world: .init(),
        scene: SimpleStory.initialScene()
      )
    )

    await runner.start()
  }
}
