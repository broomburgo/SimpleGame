import Foundation
import Narratore
import SimpleSetting

private let directoryPath = "SimpleGameSupportingFiles"
private let filePath = "\(directoryPath)/Status.json"

public final class SimpleHandler<Game: Story> {
  public init() {}
  
  public func askToRestoreStatusIfPossible() -> Status<Game>? {
    let useFile: Bool
    if fm.fileExists(atPath: filePath) {
      print("""
      A Narratore status file was found at '\(filePath)': do you want to continue where you left?
      "[Valid inputs: y, n. Hit RETURN after entering a valid input.]"
      """)
      useFile = input(accepted: ["y", "n"]) == "y"
    } else {
      useFile = false
    }

    guard useFile else {
      return nil
    }

    guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
      print("""
      Cannot read file, will start story from scratch.
      """)
      return nil
    }

    do {
      return try decoder.decode(Status<Game>.self, from: data)
    } catch {
      print("""
      Cannot read file, will start story from scratch.
      ERROR: \(error)
      """)
      return nil
    }
  }

  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  private let fm = FileManager.default
  
  private func input(accepted: [String]) -> String {
    while true {
      guard let captured = readLine(), accepted.contains(captured) else {
        print("[Invalid input. Valid inputs: \(accepted.joined(separator: ", "))]")
        continue
      }
      return captured
    }
  }
}

extension SimpleHandler: Handler {
  public func acknowledge(narration: Player<Game>.Narration) async -> Next<Game, Void> {
    if !narration.tags.isEmpty {
      print("[\(narration.tags.map { "\($0)" }.joined(separator: "|"))]")
    }
    
    for message in narration.messages {
      print(message)

      _ = readLine()
    }

    return .advance
  }

  public func make(choice: Player<Game>.Choice) async -> Next<Game, Player<Game>.Option> {
    for (index, option) in choice.options.enumerated() {
      print(index, "-", option.message)
    }

    let received = input(accepted: choice.options.indices.map { "\($0)" })

    guard
      let selected = Int(received),
      choice.options.indices.contains(selected)
    else {
      print("[Invalid option. Valid options: \(choice.options.indices)]")
      return .replay
    }

    return .advance(with: choice.options[selected])
  }
  
  public func handle(event: Player<Game>.Event) {
    switch event {
    case .statusUpdated(let status):
      guard let data = try? encoder.encode(status) else {
        break
      }
      let currentDirectory = fm.currentDirectoryPath
      try? fm.createDirectory(atPath: "\(currentDirectory)/\(directoryPath)", withIntermediateDirectories: true)
      try? fm.removeItem(atPath: "\(currentDirectory)/\(filePath)")
      try? data.write(to: URL(fileURLWithPath: "\(currentDirectory)/\(filePath)"))
      
    case .gameStarted(let status):
      print("""
      Welcome to Narratore!
      This is a simple game engine created to run Narratore stories
      in the command line.
      This shouldn't be considered a production-ready application,
      but a basic showcase of the features of Narratore.
      Nevertheless, it works, so feel free to use and reuse the code as you see fit.
      
      This engine saves the game state at every step into
      '\(filePath)', from the current working directory.
      If you launched this by double-clicking on it, the current working directory
      will likely be your home folder.
      You can exit at any time by pressing 'ctrl-c': next time you launch this,
      it'll check for a previously saved state.
      
      To advance the story after some text is shown (or some error is received)
      just hit RETURN.
      To select an option when a choice is presented, press the
      assigned number (0, 1, 2, 3...) and then hit RETURN.
      
      Enjoy!
      """)

      _ = readLine()

      for message in status.info.script.words.suffix(4) {
        print(message)
      }

    case .gameEnded:
      print("The story ended. Until next time.")
      try? fm.removeItem(atPath: filePath)

    case .errorProduced(let failure):
      print("ERROR: \(failure)")
    }
  }
}
