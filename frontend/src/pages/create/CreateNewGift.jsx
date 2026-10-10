import { Button } from "../../components/elements/Button/Button";
import { useGiftStore } from "../../stores/useGiftStore";
import { useParams, useNavigate } from "react-router-dom";
import { customSwal } from "../../utils/customSwal";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import EditCalendarRoundedIcon from "@mui/icons-material/EditCalendarRounded";
import dayjs from "dayjs";
import "./create.css";

// Component for creating a new gift
export const CreateNewGift = () => {
    const { giftName, setGiftName, addGift, tags, setTags, dueDate, setDueDate } = useGiftStore();
    const { id } = useParams();
    const hiveId = id;
    const navigate = useNavigate();

    // Function to handle navigation back to the hive
    const handleOnclickNavigation = () => {
        navigate(`/hives/${hiveId}`)
    };

    // function to handle adding a new gift
    const handleAddGift = async (event) => {
        event.preventDefault();

        // Formats the tags so that they are saved as an array with several strings instead of one string. Filters out empty tags
        const formattedTags = typeof tags === "string" ?
            tags.split(",")
                .map(tag => tag.trim())
                .filter(tag => tag !== "")
            : [];

        const giftData = {
            gift: giftName,
            tags: formattedTags,
            dueDate: dueDate,
        };

        // Check if the due date is in the past
        if (dueDate && dayjs(dueDate).isBefore(dayjs())) {
            customSwal.fire({
                title: "Oops...",
                text: "The due date must be in the future!",
                icon: "error",
                confirmButtonText: "OK",
            });
            return; // Exit the function early
        }

        try {
            await addGift(giftData, hiveId);
            setGiftName("");
            setTags("");
            setDueDate(null);

            // Alerts to the user that the gift has been created and gives them the choice to either add another gift or go back to their hive
            customSwal.fire({
                title: "Weee!",
                text: "Gift successfully added! 🎁",
                icon: "success",
                showCancelButton: true,
                confirmButtonText: "Let's add another!",
                cancelButtonText: "Back to my hive",
            }).then((result) => {
                if (result.isConfirmed) {
                    setGiftName("");
                    setTags("");
                    setDueDate(null);
                } else if (result.dismiss === customSwal.DismissReason.cancel) {
                    navigate(`/hives/${hiveId}`);
                }
            });
        } catch (error) {
            console.error("There was an error =>", error);
        }
    }

    return (
        <section>
            <h1>Add a new gift</h1>
            <form className="form-wrapper" onSubmit={handleAddGift}>
                <div className="form-group">
                    <label htmlFor="giftName">Gift</label>
                    <input
                        type="text"
                        id="giftName"
                        placeholder="e.g. New phone"
                        value={giftName}
                        onChange={(e) => setGiftName(e.target.value)}
                        required />
                </div>
                <div className="form-group">
                    <label htmlFor="tags">Add tags (separated by comma)</label>
                    <input
                        type="text"
                        id="tags"
                        placeholder="e.g. christmas, 2023"
                        value={tags}
                        onChange={(e) => setTags(e.target.value)}
                        required />
                </div>
                <div className="form-group">
                    <label htmlFor="dueDate">Set due date</label>
                    <DatePicker
                        className="customDatePickerInput"
                        id="dueDate"
                        value={dueDate ? dayjs(dueDate) : null}
                        onChange={setDueDate}
                        slots={{
                            openPickerIcon: EditCalendarRoundedIcon,
                        }}
                        slotProps={{
                            openPickerButton: { color: "primary" },
                            textField: {
                                variant: "outlined",
                                fullWidth: true,
                            },
                        }}
                    />
                </div>
            </form>

            <div className="btns">
                <Button handleOnClick={handleAddGift} className={"primary"} btnText={"Add gift"} />
                <Button className={"secondary"} handleOnClick={handleOnclickNavigation} btnText={"Back to hive"} />
            </div>
        </section>
    )
}