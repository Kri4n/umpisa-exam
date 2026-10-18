import app from "../src/app";
import { connectDB, disconnectDB } from "../src/config/db";
import { bootstrap } from "../src/server";

jest.mock("../src/app", () => ({
  __esModule: true,
  default: { listen: jest.fn() },
}));
jest.mock("../src/config/db", () => ({
  connectDB: jest.fn(),
  disconnectDB: jest.fn(),
}));
jest.mock("../src/config/env", () => ({
  env: { PORT: 4321 },
}));

const mockedListen = jest.mocked(app.listen);
const mockedConnectDB = jest.mocked(connectDB);
const mockedDisconnectDB = jest.mocked(disconnectDB);

describe("bootstrap", () => {
  const close = jest.fn();
  let closeCallback: ((error?: Error) => void) | undefined;
  let log: jest.SpyInstance;

  beforeEach(() => {
    jest.clearAllMocks();
    mockedConnectDB.mockResolvedValue();
    mockedDisconnectDB.mockResolvedValue();
    mockedListen.mockReturnValue({ close } as never);
    closeCallback = undefined;
    close.mockImplementation((callback?: (error?: Error) => void) => {
      closeCallback = callback;
    });
    log = jest.spyOn(console, "log").mockImplementation(() => undefined);
  });

  afterEach(() => {
    log.mockRestore();
    jest.restoreAllMocks();
  });

  it("connects to the database before listening on the configured port", async () => {
    await bootstrap();

    expect(mockedConnectDB).toHaveBeenCalledTimes(1);
    expect(mockedListen).toHaveBeenCalledWith(4321, "0.0.0.0", expect.any(Function));
    expect(mockedConnectDB.mock.invocationCallOrder[0]).toBeLessThan(
      mockedListen.mock.invocationCallOrder[0],
    );
  });

  it("closes the server and disconnects from the database on shutdown signals", async () => {
    const processOn = jest.spyOn(process, "on");
    const processExit = jest.spyOn(process, "exit").mockImplementation(() => undefined as never);

    await bootstrap();

    const sigintHandler = processOn.mock.calls.find(([signal]) => signal === "SIGINT")?.[1];
    const sigtermHandler = processOn.mock.calls.find(([signal]) => signal === "SIGTERM")?.[1];

    expect(sigintHandler).toEqual(expect.any(Function));
    expect(sigtermHandler).toEqual(expect.any(Function));
    expect(sigtermHandler).toBe(sigintHandler);

    (sigintHandler as () => void)();
    expect(close).toHaveBeenCalledTimes(1);
    expect(mockedDisconnectDB).not.toHaveBeenCalled();

    closeCallback?.();
    expect(mockedDisconnectDB).toHaveBeenCalledTimes(1);

    await new Promise<void>((resolve) => setImmediate(resolve));

    expect(processExit).toHaveBeenCalledWith(0);
  });

  it("does not start listening when the database connection fails", async () => {
    const error = new Error("database unavailable");
    mockedConnectDB.mockRejectedValue(error);

    await expect(bootstrap()).rejects.toBe(error);

    expect(mockedListen).not.toHaveBeenCalled();
  });
});
